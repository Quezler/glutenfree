local util = require('util')

local function on_configuration_changed(event)
  global.lab_inputs = {}
  for _, entity_prototype in pairs(game.get_filtered_entity_prototypes({{filter = 'type', type = 'lab'}})) do
    global.lab_inputs[entity_prototype.name] = util.list_to_map(entity_prototype.lab_inputs)
  end
end

script.on_configuration_changed(on_configuration_changed)

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
  }
end

script.on_init(function(event)
  global.structs = {}

  on_configuration_changed()

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = 'lab'})) do
      on_created_entity({entity = entity})
    end
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'type', type = 'lab'},
  })
end

local Flasks = {}

Flasks.frame_name = 'show_missing_bottles_for_current_research_frame'
Flasks.window_name = 'show_missing_bottles_for_current_research_window'
Flasks.label_name = 'show_missing_bottles_for_current_research_label'

function Flasks.update_player(player, caption)
  if script.level.is_simulation then return end

  local frame = player.gui.screen[Flasks.frame_name]
  if not frame or not frame.valid then
    frame = player.gui.screen.add({
      type = "frame",
      name = Flasks.frame_name,
      style = Flasks.frame_name,
      direction = "horizontal",
      ignored_by_interaction = true,
    })
  end

  -- canceling a research causes the "press T to start a new research" to come ontop layer-wise,
  -- so to bodge that we'll just remove the frame entirely when there's ever no pending research.
  if not player.force.current_research then
    frame.destroy()
    return
  end

  local window = frame[Flasks.window_name]
  if not window or not window.valid then
    window = frame.add({
      type = "frame",
      name = Flasks.window_name,
      style = Flasks.window_name,
      direction = "horizontal",
      -- ignored_by_interaction = true,
    })
    window.style.width = 256 -- 192 for 0.75 display scale
    -- window.style.margin = 4
    window.style.padding = 8
    window.style.left_padding = 8 + 1
    window.style.top_padding = 46
  end

  local label = window[Flasks.label_name]
  if not label or not label.valid then
    label = window.add({
      type = "label",
      name = Flasks.label_name,
      style = Flasks.label_name,
    })
  end
  label.caption = caption

  Flasks.resize_player(player)
end

local function on_active_research_changed(event)
  for _, player in ipairs(game.connected_players) do
    local current_research = player.force.current_research
    local list = {}
    if current_research then
      for _, research_unit_ingredient in ipairs(current_research.research_unit_ingredients) do
        if #list >= 12 then break end
        table.insert(list, string.format("[img=item/%s]", research_unit_ingredient.name))
        -- table.insert(list, string.format("[img=item/%s]", research_unit_ingredient.name))
      end
      -- game.print(table.concat(list, ' '))
    end
    -- log('on_active_research_changed')
    Flasks.update_player(player, table.concat(list, ''))
  end
end

script.on_nth_tick(60, on_active_research_changed)

function Flasks.resize_player(player_or_event)
  local player = player_or_event.object_name == "LuaPlayer" and player_or_event or game.get_player(player_or_event.player_index)
  local frame = player.gui.screen[Flasks.frame_name]
  if not frame or not frame.valid then return end

  frame.style.height = player.display_resolution.height / player.display_scale
  frame.style.width = player.display_resolution.width / player.display_scale
end

script.on_event(defines.events.on_player_display_resolution_changed, Flasks.resize_player)
script.on_event(defines.events.on_player_display_scale_changed, Flasks.resize_player)

for _, event in ipairs({
  defines.events.on_research_cancelled,
  defines.events.on_research_finished,
  defines.events.on_research_started,
}) do
  script.on_event(event, on_active_research_changed)
end
