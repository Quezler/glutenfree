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
    -- unit_number = entity.unit_number,
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

Flasks.frame_name  = 'show_missing_bottles_for_current_research_frame'
Flasks.window_name = 'show_missing_bottles_for_current_research_window'
Flasks.label_name  = 'show_missing_bottles_for_current_research_label'

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
  else
    -- canceling a research causes the "press T to start a new research" to come ontop layer-wise,
    -- so to bodge that we'll just bring the frame to front when there's ever no pending research.
    frame.bring_to_front()
  end

  local window = frame[Flasks.window_name]
  if not window or not window.valid then
    window = frame.add({
      type = "frame",
      name = Flasks.window_name,
      style = Flasks.window_name,
      direction = "horizontal",
    })
    window.style.width = 256
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

local function get_missing_counts(force, list)
  local missing_counts = {}

  for unit_number, struct in pairs(global.structs) do
    if not struct.entity.valid then
      global.structs[unit_number] = nil
    else

      if struct.entity.force == force then
        if struct.entity.status == defines.entity_status.missing_science_packs then
          local inventory = struct.entity.get_inventory(defines.inventory.lab_input)
          for _, item_name in ipairs(list) do
            if global.lab_inputs[struct.entity.name][item_name] then -- ignore labs that cannot use this item
              if inventory.get_item_count(item_name) == 0 then
                -- game.print(serpent.line({
                --   item_name,
                --   struct.entity.name,
                --   struct.entity.surface.name,
                --   struct.entity.position
                -- }))
                missing_counts[item_name] = (missing_counts[item_name] or 0) + 1
              end
            end
          end
        end
      end

    end
  end

  return missing_counts
end

local function intersect_array_with_map(array, map, threshold)
  local output = {}

  for _, string in ipairs(array) do
    if map[string] and map[string] > threshold then
      table.insert(output, string)
    end
  end

  return output
end

local function string_item_name_array_to_rich_text_string(item_names)
  local string = ""

  for _, item_name in ipairs(item_names) do
    string = string .. string.format("[img=item/%s]", item_name)
  end

  return string
end

local function on_active_research_changed(event)
  local concat_for_force = {}

  for _, player in ipairs(game.connected_players) do
    if not concat_for_force[player.force.index] then
      local current_research = player.force.current_research
      local desired_list = {}
      if current_research then
        for _, research_unit_ingredient in ipairs(current_research.research_unit_ingredients) do
          if #desired_list >= 12 then break end -- 12 rich texts can fit inside the active research bar
          table.insert(desired_list, research_unit_ingredient.name)
        end

        local missing_counts = get_missing_counts(player.force, desired_list)
        desired_list = intersect_array_with_map(desired_list, missing_counts, 1)
      end
      concat_for_force[player.force.index] = string_item_name_array_to_rich_text_string(desired_list)
    end
    Flasks.update_player(player, concat_for_force[player.force.index])
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
