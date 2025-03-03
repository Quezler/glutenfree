require("shared")
local mod = {}

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
  return data
end

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  if entity.name == mod_prefix .. "proxy-container" then
    return entity.destroy()
  end

  local entitydata = mod.create_entitydata(entity, {
    proxy = nil,
  })
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = mod_name, unit_number = entity.unit_number}

  entitydata.proxy = entity.surface.create_entity{
    name = mod_prefix .. "proxy-container",
    force = entity.force,
    position = entity.position,
  }
  entitydata.proxy.destructible = false

  if entity.last_user then
    entitydata.proxy.proxy_target_entity = entity.last_user.character
    entitydata.proxy.proxy_target_inventory = defines.inventory.character_main
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
    -- tags = {unit_number = entity.unit_number},
  }

  local player_dropdown = inner.add{
    type = "drop-down",
    items = {
      {"character-inventory-uplink.select-player"},
    },
    selected_index = 1,
  }
  player_dropdown.style.horizontally_stretchable = true
  player_dropdown.style.bottom_margin = 12
  local items = player_dropdown.items
  for _, player in ipairs(entity.force.players) do
    table.insert(items, player.name)
  end
  player_dropdown.items = items

  local inventory_dropdown = inner.add{
    type = "drop-down",
    items = {
      {"character-inventory-uplink.select-inventory"},
      {"character-inventory-uplink.character-main"},
      {"character-inventory-uplink.character-guns"},
      {"character-inventory-uplink.character-ammo"},
      {"character-inventory-uplink.character-armor"},
      {"character-inventory-uplink.character-vehicle"},
      {"character-inventory-uplink.character-trash"},
    },
    selected_index = 1,
  }
  inventory_dropdown.style.horizontally_stretchable = true
end
