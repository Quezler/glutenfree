local circuit_red = defines.wire_connector_id.circuit_red
local circuit_green = defines.wire_connector_id.circuit_green

local Handler = {}

local function refresh_always_show_and_show_in_chart(struct)
  local entity = struct.entity
  local inventory = game.create_inventory(1)

  inventory.insert({name = "blueprint"})
  inventory[1].create_blueprint{
    surface = entity.surface,
    force = entity.force,
    area = entity.bounding_box,
  }

  local blueprint_entities = inventory[1].get_blueprint_entities() or {}
  assert(#blueprint_entities == 1)

  struct.always_show = blueprint_entities[1].always_show == true
  struct.show_in_chart = blueprint_entities[1].show_in_chart == true

  -- game.print(serpent.line({always_show = struct.always_show, show_in_chart = struct.show_in_chart}))

  inventory.destroy()
end

local function get_alt_mode(player_index)
  if storage.alt_mode[player_index] == nil then
    storage.alt_mode[player_index] = game.get_player(player_index).game_view_settings.show_entity_info
  end

  return storage.alt_mode[player_index]
end

local function refresh_observed_surfaces()
  storage.observed_surfaces = {}

  for _, player in ipairs(game.connected_players) do
    storage.observed_surfaces[player.surface.index] = true
  end
end

function Handler.on_init()
  storage.structs = {}
  storage.structs_on_surface = {}

  for _, surface in pairs(game.surfaces) do
    storage.structs_on_surface[surface.index] = {}
    for _, entity in pairs(surface.find_entities_filtered{type = "display-panel"}) do
      Handler.on_created_entity({entity = entity})
    end
  end

  storage.active_selections = {}
  storage.active_guis = {}
  storage.alt_mode = {}

  refresh_observed_surfaces()
end

function Handler.on_configuration_changed()
  --
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct_id = entity.unit_number
  storage.structs[struct_id] = {
    id = entity.unit_number,
    entity = entity,

    last_tick = 0,
    always_show = false,
    show_in_chart = false,
  }

  storage.structs_on_surface[entity.surface.index][struct_id] = true

  refresh_always_show_and_show_in_chart(storage.structs[struct_id])
end

local function is_nil_or_number(string)
  return string == nil or tonumber(string, 10) ~= nil
end

local function tick_display_panel(struct, tick)
  if struct.last_tick == tick then return end
  struct.last_tick = tick

  local entity = struct.entity
  game.print(string.format("@%d ticked display panel #%d", tick, entity.unit_number))

  local cb = entity.get_control_behavior()
  if cb == nil then return end -- entity never had a wire connected yet

  for i, message in ipairs(cb.messages) do
    if is_nil_or_number(message.text) then
      if message.condition and message.condition.first_signal then
        message.text = entity.get_signal(message.condition.first_signal, circuit_red, circuit_green)
      else
        message.text = ""
      end
      cb.set_message(i, message)
    end
  end
end

script.on_init(Handler.on_init)
script.on_configuration_changed(Handler.on_configuration_changed)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "type", type = "display-panel"},
  })
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected
  if entity and entity.type == "display-panel" then
    storage.active_selections[player.index] = {
      player = player,
      entity = entity,
    }
    tick_display_panel(storage.structs[entity.unit_number], event.tick)
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity
  if entity and entity.type == "display-panel" then
    storage.active_guis[player.index] = {
      player = player,
      entity = entity,
    }
    tick_display_panel(storage.structs[entity.unit_number], event.tick)
  end
end)

script.on_event(defines.events.on_tick, function(event)
  -- for _, struct in pairs(storage.structs) do
  --   if struct.entity.valid then
  --     tick_display_panel(struct, event.tick)
  --   end
  -- end

  for surface_index, _ in pairs(storage.observed_surfaces) do
    for struct_id, _ in pairs(storage.structs_on_surface[surface_index]) do
      tick_display_panel(storage.structs[struct_id], event.tick)
    end
  end

  -- for player_index, active_selection in pairs(storage.active_selections) do
  --   local player = active_selection.player
  --   local entity = active_selection.entity
  --   if player.valid and player.selected == entity and player.connected then
  --     tick_display_panel(storage.structs[entity.unit_number], event.tick)
  --   else
  --     storage.active_selections[player_index] = nil
  --   end
  -- end

  -- storage.active_guis = storage.active_guis or {}
  -- for player_index, active_gui in pairs(storage.active_guis) do
  --   local player = active_gui.player
  --   local entity = active_gui.entity
  --   local struct = storage.structs[entity.unit_number]
  --   if player.valid and player.opened == entity and player.connected then
  --     if get_alt_mode(player_index) then
  --     tick_display_panel(struct, event.tick)
  --     end
  --   else
  --     refresh_always_show_and_show_in_chart(struct)
  --     storage.active_guis[player_index] = nil
  --   end
  -- end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local entity = event.destination
  if entity.type == "display-panel" then
    refresh_always_show_and_show_in_chart(storage.structs[entity.unit_number])
  end
end)

script.on_event(defines.events.on_player_toggled_alt_mode, function(event)
  storage.alt_mode[event.player_index] = event.alt_mode
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  refresh_observed_surfaces()
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  refresh_observed_surfaces()
end)

script.on_event(defines.events.on_player_left_game, function(event)
  refresh_observed_surfaces()
end)

script.on_event(defines.events.on_surface_created, function(event)
  storage.structs_on_surface[event.surface_index] = {}
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.structs_on_surface[event.surface_index] = nil
end)
