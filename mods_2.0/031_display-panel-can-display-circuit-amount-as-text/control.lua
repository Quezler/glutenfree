local circuit_red = defines.wire_connector_id.circuit_red
local circuit_green = defines.wire_connector_id.circuit_green

require("util")

local Handler = {}

local function refresh_always_show_and_show_in_chart(struct)
  local entity = struct.entity
  if entity.to_be_deconstructed() then return end

  local inventory = game.create_inventory(1)

  inventory.insert({name = "blueprint"})
  inventory[1].create_blueprint{
    surface = entity.surface,
    force = entity.force,
    area = entity.bounding_box,
  }

  local blueprint_entities = inventory[1].get_blueprint_entities() or {}
  assert(#blueprint_entities == 1)
  inventory.destroy()

  struct.always_show = blueprint_entities[1].always_show == true
  struct.show_in_chart = blueprint_entities[1].show_in_chart == true
  -- game.print(serpent.line({always_show = struct.always_show, show_in_chart = struct.show_in_chart}))

  local surfacedata = storage.surfacedata[entity.surface.index]
  surfacedata.struct_ids_to_show_in_chart[struct.id] = struct.show_in_chart and true or nil
end

local function refresh_observed_surfaces()
  storage.observed_surfaces = {}

  for _, player in ipairs(game.connected_players) do
    storage.observed_surfaces[player.surface.index] = true
  end
end

local function refresh_surface_to_alt_mode_players()
  storage.surface_to_alt_mode_players = {}

  for _, player in ipairs(game.connected_players) do
    if storage.alt_mode[player.index] then
      storage.surface_to_alt_mode_players[player.surface.index] = storage.surface_to_alt_mode_players[player.surface.index] or {}
      storage.surface_to_alt_mode_players[player.surface.index][player.index] = player
    end
  end
end

local function alt_player_is_nearby(alt_mode_players, position)
  for player_index, player in pairs(alt_mode_players) do
    -- game.print(util.distance(position, player.position))
    -- game.print(player.render_mode)
      if player.render_mode == defines.render_mode.game then
      if 120 > util.distance(position, player.position) then -- 120 is just beyond my screen when i fully zoom out
        return true
      end
    end
  end
end

function Handler.on_init()
  storage.structs = {}
  storage.surfacedata = {}
  storage.deathrattles = {}

  storage.alt_mode = {}
  for _, player in pairs(game.players) do
    Handler.on_player_created({player_index = player.index})
  end

  storage.ticked_this_tick = 0
  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
    for _, entity in pairs(surface.find_entities_filtered{type = "display-panel"}) do
      Handler.on_created_entity({entity = entity})
    end
  end

  storage.active_selections = {}
  storage.active_guis = {}

  storage.observed_surfaces = {}
  refresh_observed_surfaces()

  storage.surface_to_alt_mode_players = {} -- surface_index nil if no players
  refresh_surface_to_alt_mode_players()
end

function Handler.on_configuration_changed()
  for _, surface in pairs(game.surfaces) do
    if storage.surfacedata[surface.index] == nil then
      Handler.on_surface_created({surface_index = surface.index})
    end
  end
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
    do_not_auto_tick_until = 0,

    surface_index = entity.surface.index,
  }

  storage.surfacedata[entity.surface.index].struct_ids[struct_id] = true
  storage.deathrattles[script.register_on_object_destroyed(entity)] = struct_id

  refresh_always_show_and_show_in_chart(storage.structs[struct_id])
end

local function is_nil_or_number(string)
  return string == nil or tonumber(string, 10) ~= nil
end

local function tick_display_panel(struct, tick)
  if struct.last_tick == tick then return end
  struct.last_tick = tick

  -- storage.ticked_this_tick = storage.ticked_this_tick + 1

  local entity = struct.entity
  -- game.print(string.format("@%d ticked display panel #%d", tick, entity.unit_number))

  local cb = entity.get_control_behavior()
  if cb == nil then struct.do_not_auto_tick_until = tick + 60 * 60 return end -- entity never had a wire connected yet

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

  local red = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  local green = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
  if (red == nil and green == nil) then
    struct.do_not_auto_tick_until = tick + 60 * 10
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
  for surface_index, _ in pairs(storage.observed_surfaces) do
    local surfacedata = storage.surfacedata[surface_index]

    for struct_id, _ in pairs(surfacedata.struct_ids_to_show_in_chart) do
      local struct = storage.structs[struct_id]
      if event.tick >= struct.do_not_auto_tick_until then
        tick_display_panel(storage.structs[struct_id], event.tick)
      end
    end

    -- are there any players on this surface with alt mode on?
    local alt_mode_players = storage.surface_to_alt_mode_players[surface_index]
    if alt_mode_players then
      for struct_id, _ in pairs(surfacedata.struct_ids) do
        local struct = storage.structs[struct_id]
        if struct.always_show and event.tick >= struct.do_not_auto_tick_until and struct.entity.valid and alt_player_is_nearby(alt_mode_players, struct.entity.position) then
          tick_display_panel(struct, event.tick)
        end
      end
    end
  end

  for player_index, active_selection in pairs(storage.active_selections) do
    local player = active_selection.player
    local entity = active_selection.entity
    if player.valid and player.selected == entity and player.connected then
      tick_display_panel(storage.structs[entity.unit_number], event.tick)
    else
      storage.active_selections[player_index] = nil
      if entity.valid then
        storage.structs[entity.unit_number].do_not_auto_tick_until = 0
      end
    end
  end

  storage.active_guis = storage.active_guis or {}
  for player_index, active_gui in pairs(storage.active_guis) do
    local player = active_gui.player
    local entity = active_gui.entity
    local struct = storage.structs[entity.unit_number]
    if player.valid and player.opened == entity and player.connected then
      -- if storage.alt_mode[player_index] then
      tick_display_panel(struct, event.tick)
      -- end
    else
      refresh_always_show_and_show_in_chart(struct)
      storage.active_guis[player_index] = nil
      struct.do_not_auto_tick_until = 0
    end
  end

  -- game.print('ticked_this_tick: ' .. storage.ticked_this_tick)
  -- storage.ticked_this_tick = 0
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local entity = event.destination
  if entity.type == "display-panel" then
    refresh_always_show_and_show_in_chart(storage.structs[entity.unit_number])
  end
end)

script.on_event(defines.events.on_player_toggled_alt_mode, function(event)
  storage.alt_mode[event.player_index] = event.alt_mode
  refresh_surface_to_alt_mode_players()
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
  refresh_observed_surfaces()
  refresh_surface_to_alt_mode_players()
end)

script.on_event(defines.events.on_player_joined_game, function(event)
  refresh_observed_surfaces()
  refresh_surface_to_alt_mode_players()
end)

script.on_event(defines.events.on_player_left_game, function(event)
  refresh_observed_surfaces()
  refresh_surface_to_alt_mode_players()
end)

function Handler.on_surface_created(event)
  storage.surfacedata[event.surface_index] = {
    struct_ids = {},
    struct_ids_to_show_in_chart = {},
  }
end

script.on_event(defines.events.on_surface_created, Handler.on_surface_created)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.surfacedata[event.surface_index] = nil
  storage.observed_surfaces[event.surface_index] = nil
  storage.surface_to_alt_mode_players[event.surface_index] = nil
end)

function Handler.on_player_created(event)
  storage.alt_mode[event.player_index] = game.get_player(event.player_index).game_view_settings.show_entity_info
end

script.on_event(defines.events.on_player_created, on_player_created)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct_id = assert(deathrattle)
    local struct = assert(storage.structs[struct_id])

    storage.structs[struct_id] = nil
    storage.surfacedata[struct.surface_index].struct_ids[struct_id] = nil
    storage.surfacedata[struct.surface_index].struct_ids_to_show_in_chart[struct_id] = nil
  end
end)
