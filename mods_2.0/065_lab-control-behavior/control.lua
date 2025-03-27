require("shared")
local mod = {}

local gui_frame_name = mod_prefix .. "frame"
local gui_inner_name = mod_prefix .. "inner"
local gui_radio_single = mod_prefix .. "single"
local gui_radio_surface = mod_prefix .. "surface"
local gui_radio_surfaces = mod_prefix .. "surfaces"

script.on_init(function()
  storage.entitydata = {}
  storage.deathrattles = {}
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "lab"})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

local on_created_entity_filter = {
  {filter = "type", type = "lab"},
}

local is_lab_control_behavior = {}
for _, prototype in pairs(prototypes.get_entity_filtered{{filter="type", type="lab"}}) do
  local proxy = prototypes.entity[mod_prefix .. prototype.name .. "-control-behavior"]
  if proxy then
    is_lab_control_behavior[proxy.name] = true
    table.insert(on_created_entity_filter, {filter = "name", name = proxy.name})
  end
end

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  if is_lab_control_behavior[entity.name] then return entity.destroy() end
  local struct = nil
  -- game.print("new lab registered: " .. tostring(entity))

  local cb_name = mod_prefix .. entity.name .. "-control-behavior"
  if not prototypes.entity[cb_name] then return end -- data final fixes?

  -- in case of a quality upgrade we take on the wire connections just before that entity gets purged by the deathrattle
  local other_wire_proxy = entity.surface.find_entities_filtered{
    name = cb_name,
    position = entity.position,
    radius = 0,
    limit = 1,
  }[1]
  if other_wire_proxy then
    local entitydata = storage.entitydata[other_wire_proxy.unit_number]
    assert(entitydata)

    struct = storage.structs[entitydata.struct_id]
    assert(struct)

    storage.structs[struct.id] = nil
    struct.id = entity.unit_number
    storage.structs[struct.id] = struct
    struct.entity = entity
    entitydata.struct_id = struct.id
  end

  if struct == nil then
    struct = new_struct(storage.structs, {
      id = entity.unit_number,
      entity = entity,

      mode = gui_radio_single,

      wire_proxy = nil,
      wire_proxy_red = nil,
      wire_proxy_green = nil,
      item_proxy = nil,
      proxies = {},
    })

    local wire_proxy = entity.surface.create_entity{
      name = cb_name,
      force = entity.force,
      position = {entity.position.x, entity.position.y + 1},
    }
    wire_proxy.destructible = false
    struct.wire_proxy = wire_proxy
    struct.wire_proxy_red = struct.wire_proxy.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    struct.wire_proxy_green = struct.wire_proxy.get_wire_connector(defines.wire_connector_id.circuit_green, true)

    storage.entitydata[wire_proxy.unit_number] = {entity = wire_proxy, struct_id = struct.id}
    storage.deathrattles[script.register_on_object_destroyed(wire_proxy)] = {name = "entitydata", unit_number = wire_proxy.unit_number}

    local item_proxy = entity.surface.create_entity{
      name = mod_prefix .. "proxy-container",
      force = entity.force,
      position = entity.position
    }
    item_proxy.destructible = false
    item_proxy.proxy_target_entity = entity
    item_proxy.proxy_target_inventory = defines.inventory.lab_input
    struct.item_proxy = item_proxy

    local red_connector = item_proxy.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green_connector = item_proxy.get_wire_connector(defines.wire_connector_id.circuit_green, true)

    assert(struct.wire_proxy_red.connect_to(red_connector, false, defines.wire_origin.player))
    assert(struct.wire_proxy_green.connect_to(green_connector, false, defines.wire_origin.player))
  end

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "lab", unit_number = entity.unit_number}

  for _, other_struct in pairs(storage.structs) do
    if other_struct.mode ~= gui_radio_single then
      if other_struct.entity.valid then -- invalid if we're upgrading the quality of one
        mod.consider_linking_to_struct(other_struct, struct)
      end
    end
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, on_created_entity_filter)
end

function mod.open_gui(entity, player)
  local frame = player.gui.relative[gui_frame_name]
  if frame then frame.destroy() end

  local struct = storage.structs[entity.unit_number]
  assert(struct)

  frame = player.gui.relative.add{
    type = "frame",
    name = gui_frame_name,
    caption = {"gui-control-behavior.circuit-connection"},
    anchor = {
      gui = defines.relative_gui_type.lab_gui,
      position = defines.relative_gui_position.right,
    },
  }

  local inner = frame.add{
    type = "frame",
    name = gui_inner_name,
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
    tags = {unit_number = entity.unit_number},
  }

  inner.add{
    type = "radiobutton",
    name = gui_radio_single,
    caption = "Read contents",
    state = struct.mode == gui_radio_single,
  }
  inner.add{
    type = "radiobutton",
    name = gui_radio_surface,
    caption = "Read contents (surface)",
    state = struct.mode == gui_radio_surface,
  }
  inner.add{
    type = "radiobutton",
    name = gui_radio_surfaces,
    caption = "Read contents (surfaces)",
    state = struct.mode == gui_radio_surfaces,
  }
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity

  if entity then
    if entity.type == "lab" then
      local player = game.get_player(event.player_index) --[[@as LuaEntity]]
      mod.open_gui(entity, player)
    elseif is_lab_control_behavior[entity.name] then
      local lab = entity.surface.find_entities_filtered{
        type = "lab",
        position = entity.position,
        limit = 1,
      }[1]
      if lab then
        local player = game.get_player(event.player_index) --[[@as LuaEntity]]
        player.opened = lab
      end
    end
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  local element = event.element
  if element.parent.name == gui_inner_name then
    element.parent[gui_radio_single].state = false
    element.parent[gui_radio_surface].state = false
    element.parent[gui_radio_surfaces].state = false
    element.parent[element.name].state = true

    local struct = storage.structs[element.parent.tags.unit_number]
    if struct then
      mod.set_mode(struct, element.name)
    end
  end
end)

function mod.set_mode(struct, mode)
  if struct.mode == mode then return end
  struct.mode = mode
  -- game.print(mode)

  for _, proxy in pairs(struct.proxies) do
    proxy.entity.destroy()
  end
  struct.proxies = {}

  -- in single mode there are no other proxies required
  if struct.mode == gui_radio_single then return end

  for _, other_struct in pairs(storage.structs) do
    mod.consider_linking_to_struct(struct, other_struct)
  end
end

function mod.consider_linking_to_struct(source_struct, target_struct)
  if target_struct.entity.force == source_struct.entity.force then
    if source_struct.mode == gui_radio_surfaces or target_struct.entity.surface == source_struct.entity.surface then
      local proxy = source_struct.entity.surface.create_entity{
        name = mod_prefix .. "proxy-container",
        force = source_struct.entity.force,
        position = source_struct.entity.position
      }
      proxy.destructible = false
      proxy.proxy_target_entity = target_struct.entity
      proxy.proxy_target_inventory = defines.inventory.lab_input
      source_struct.proxies[proxy.unit_number] = {entity = proxy}

      local red_connector = proxy.get_wire_connector(defines.wire_connector_id.circuit_red, true)
      local green_connector = proxy.get_wire_connector(defines.wire_connector_id.circuit_green, true)

      assert(source_struct.wire_proxy_red.connect_to(red_connector, false, defines.wire_origin.script))
      assert(source_struct.wire_proxy_green.connect_to(green_connector, false, defines.wire_origin.script))

      -- we do not need to bother deathrattling this proxy container when the entity target dies,
      -- it just stops reading the signals and will clean itself up again someday, not very pressing.
    end
  end
end

local deathrattles = {
  ["lab"] = function (deathrattle)
    local struct = storage.structs[deathrattle.unit_number]
    if struct then storage.structs[deathrattle.unit_number] = nil
      struct.wire_proxy.destroy()
      struct.item_proxy.destroy()
      for _, proxy in pairs(struct.proxies) do
        proxy.entity.destroy()
      end
    end
  end,
  ["entitydata"] = function (deathrattle)
    storage.entitydata[deathrattle.unit_number] = nil
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)
