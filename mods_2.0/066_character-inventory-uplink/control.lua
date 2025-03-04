require("shared")
local mod = {}

-- todo: deactivate when not actively linked
-- todo: admin check
-- todo: check_player performance
-- todo: luarendered labels

script.on_init(function ()
  storage.entitydata = {}
  storage.deathrattles = {}
end)

mod.on_created_entity_filters = {
  {filter = "name", name = mod_name},
  {filter = "name", name = mod_prefix .. "proxy-container"},
}

function mod.create_entitydata(entity, data)
  data.entity = entity
  data.unit_number = entity.unit_number
  storage.entitydata[entity.unit_number] = data
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = entity.name, unit_number = entity.unit_number}
  return data
end

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == mod_prefix .. "proxy-container" then
    return entity.destroy()
  end

  local entitydata = mod.create_entitydata(entity, {
    proxy = nil,

    player = nil,
    inventory_index = 0,
  })

  entitydata.proxy = entity.surface.create_entity{
    name = mod_prefix .. "proxy-container",
    force = entity.force,
    position = entity.position,
  }
  entitydata.proxy.destructible = false

  do
    local red_wire = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local green_wire = entity.get_wire_connector(defines.wire_connector_id.circuit_green, true)

    local proxy_red_wire = entitydata.proxy.get_wire_connector(defines.wire_connector_id.circuit_red, true)
    local proxy_green_wire = entitydata.proxy.get_wire_connector(defines.wire_connector_id.circuit_green, true)

    assert(red_wire.connect_to(proxy_red_wire, false, defines.wire_origin.script))
    assert(green_wire.connect_to(proxy_green_wire, false, defines.wire_origin.script))
  end

  -- todo: admin check with entity.last_user or something

  local cb = entity.get_or_create_control_behavior()
  local logistic_condition = cb.logistic_condition
  -- game.print(serpent.line(logistic_condition))
  if logistic_condition.constant ~= 0 then
    mod.entitydata_set_player(entitydata, game.get_player(logistic_condition.constant))
  end
  if logistic_condition.comparator ~= "<" then
    mod.entitydata_set_inventory(entitydata, mod.roundabout_from_comparator[logistic_condition.comparator].inventory_index)
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
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

local deathrattles = {
  [mod_name] = function (deathrattle)
    local entitydata = storage.entitydata[deathrattle.unit_number]
    if entitydata then storage.entitydata[deathrattle.unit_number] = nil
      entitydata.proxy.destroy()
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity then
    if entity.name == mod_name then
      local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
      local entitydata = storage.entitydata[entity.unit_number]
      player.opened = entitydata.proxy
      mod.refresh_gui(player, entity)
    elseif entity.name == mod_prefix .. "proxy-container" then
      local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    end
  end
end)

mod.gui_frame = mod_prefix .. "gui-frame"
mod.gui_inner = mod_prefix .. "gui-inner"
mod.gui_dropdown_player = mod_prefix .. "gui-dropdown-player"
mod.gui_dropdown_inventory = mod_prefix .. "gui-dropdown-inventory"

mod.roundabouts = {
  {comparator = "<", locale = "character-inventory-uplink.select-inventory", dropdown_index = 1, inventory_index = 0                                },
  {comparator = ">", locale = "character-inventory-uplink.character-main"  , dropdown_index = 2, inventory_index = defines.inventory.character_main },
  {comparator = "=", locale = "character-inventory-uplink.character-guns"  , dropdown_index = 3, inventory_index = defines.inventory.character_guns },
  {comparator = "≥", locale = "character-inventory-uplink.character-ammo"  , dropdown_index = 4, inventory_index = defines.inventory.character_ammo },
  {comparator = "≤", locale = "character-inventory-uplink.character-armor" , dropdown_index = 5, inventory_index = defines.inventory.character_armor},
  {comparator = "≠", locale = "character-inventory-uplink.character-trash" , dropdown_index = 6, inventory_index = defines.inventory.character_trash},
}

mod.roundabout_from_comparator = {}
mod.roundabout_from_locale = {}
mod.roundabout_from_dropdown_index = {}
mod.roundabout_from_inventory_index = {}

for _, roundabout in ipairs(mod.roundabouts) do
  mod.roundabout_from_comparator[roundabout.comparator] = roundabout
  mod.roundabout_from_locale[roundabout.locale] = roundabout
  mod.roundabout_from_dropdown_index[roundabout.dropdown_index] = roundabout
  mod.roundabout_from_inventory_index[roundabout.inventory_index] = roundabout
end

function mod.refresh_gui(player, entity)
  local frame = player.gui.relative[mod.gui_frame]
  if frame then frame.destroy() end

  local entitydata = storage.entitydata[entity.unit_number]
  assert(entitydata)

  frame = player.gui.relative.add{
    type = "frame",
    name = mod.gui_frame,
    caption = {"gui-menu.settings"},
    anchor = {
      gui = defines.relative_gui_type.proxy_container_gui,
      position = defines.relative_gui_position.right,
      name = mod_prefix .. "proxy-container",
    },
  }

  local inner = frame.add{
    type = "frame",
    name = mod.gui_inner,
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
    tags = {unit_number = entity.unit_number},
  }

  local player_dropdown_index = 1
  local player_dropdown_items = {
    {"character-inventory-uplink.select-player"},
  }
  for _, player in pairs(game.players) do
    table.insert(player_dropdown_items, player.name)
    if entitydata.player and entitydata.player.name == player.name then
      player_dropdown_index = #player_dropdown_items
    end
  end
  local player_dropdown = inner.add{
    type = "drop-down",
    name = mod.gui_dropdown_player,
    items = player_dropdown_items,
    selected_index = player_dropdown_index,
  }
  player_dropdown.style.horizontally_stretchable = true
  player_dropdown.style.bottom_margin = 12

  local inventory_dropdown = inner.add{
    type = "drop-down",
    name = mod.gui_dropdown_inventory,
    items = {
      {"character-inventory-uplink.select-inventory"},
      {"character-inventory-uplink.character-main"},
      {"character-inventory-uplink.character-guns"},
      {"character-inventory-uplink.character-ammo"},
      {"character-inventory-uplink.character-armor"},
      {"character-inventory-uplink.character-trash"},
    },
    selected_index = mod.roundabout_from_inventory_index[entitydata.inventory_index].dropdown_index,
  }
  inventory_dropdown.style.horizontally_stretchable = true
end

function mod.entitydata_write_logistic_condition(entitydata)
  entitydata.entity.get_control_behavior().logistic_condition = {
    comparator = mod.roundabout_from_inventory_index[entitydata.inventory_index].comparator,
    constant = entitydata.player and entitydata.player.index or 0,
  }
end

function mod.entitydata_set_player(entitydata, player_or_nil)
  entitydata.player = player_or_nil
  if entitydata.player and entitydata.player.character then
    entitydata.proxy.proxy_target_entity = entitydata.player.character
  else
    entitydata.proxy.proxy_target_entity = nil
  end
  mod.entitydata_write_logistic_condition(entitydata)
end

function mod.entitydata_set_inventory(entitydata, index)
  entitydata.inventory_index = index
  entitydata.proxy.proxy_target_inventory = index
  mod.entitydata_write_logistic_condition(entitydata)
end

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  local element = event.element
  if element.parent.name == mod.gui_inner then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local entitydata = storage.entitydata[element.parent.tags.unit_number]
    assert(entitydata)

    if element.name == mod.gui_dropdown_player then
      local player_name = element.selected_index ~= 1 and element.items[element.selected_index] or nil
      mod.entitydata_set_player(entitydata, player_name and game.get_player(tostring(player_name)) or nil)
    elseif element.name == mod.gui_dropdown_inventory then
      mod.entitydata_set_inventory(entitydata, mod.roundabout_from_dropdown_index[element.selected_index].inventory_index)
    end
  end

end)

function mod.check_player(player)
  for _, entitydata in pairs(storage.entitydata) do
    if entitydata.player == player then
      if player.character and player.character.surface == entitydata.entity.surface then
        entitydata.proxy.proxy_target_entity = player.character
      else
        entitydata.proxy.proxy_target_entity = nil
      end
    end
  end
end

script.on_event(defines.events.on_player_controller_changed, function(event)
  -- game.print("on_player_controller_changed")
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  mod.check_player(player)
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  -- game.print("on_player_changed_surface")
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  mod.check_player(player)
end)
