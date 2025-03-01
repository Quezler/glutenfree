require("shared")
local mod = {}

local gui_frame_name = mod_prefix .. "frame"
local gui_inner_name = mod_prefix .. "inner"
local gui_radio_single = mod_prefix .. "single"
local gui_radio_surface = mod_prefix .. "surface"
local gui_radio_surfaces = mod_prefix .. "surfaces"

script.on_init(function()
  storage.deathrattles = {}
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "lab"})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,

    mode = gui_radio_single,

    proxy = nil,
    proxies = {},
  })

  game.print("new lab registered: " .. tostring(entity))

  local cb = entity.surface.create_entity{
    name = mod_prefix .. entity.name .. "-control-behavior",
    force = entity.force,
    position = {entity.position.x, entity.position.y + 1},
  }
  cb.destructible = false
  cb.proxy_target_entity = entity
  cb.proxy_target_inventory = defines.inventory.lab_input
  struct.proxy = cb
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "type", type = "lab"},
  })
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

local is_lab_control_behavior = {}
for _, prototype in pairs(prototypes.get_entity_filtered{{filter="type", type="lab"}}) do
  local proxy = prototypes.entity[mod_prefix .. prototype.name .. "-control-behavior"]
  if proxy then
    is_lab_control_behavior[proxy.name] = true
  end
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

  local red_connector = struct.proxy.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local green_connector = struct.proxy.get_wire_connector(defines.wire_connector_id.circuit_green, true)

  for _, other_struct in pairs(storage.structs) do
    if other_struct.entity.force == struct.entity.force then
      if mode == gui_radio_surfaces or other_struct.entity.surface == struct.entity.surface then
        local proxy = struct.entity.surface.create_entity{
          name = mod_prefix .. "proxy-container",
          force = struct.entity.force,
          position = struct.entity.position
        }
        proxy.destructible = false
        proxy.proxy_target_entity = other_struct.entity
        proxy.proxy_target_inventory = defines.inventory.lab_input
        struct.proxies[proxy.unit_number] = {entity = proxy}

        local other_red_connector = proxy.get_wire_connector(defines.wire_connector_id.circuit_red, true)
        local other_green_connector = proxy.get_wire_connector(defines.wire_connector_id.circuit_green, true)

        assert(red_connector.connect_to(other_red_connector, false, defines.wire_origin.script))
        assert(green_connector.connect_to(other_green_connector, false, defines.wire_origin.script))
      end
    end
  end
end
