local Zone = require('__space-exploration-scripts__.zone')

local launchpad = {}

function launchpad.init()
  global.entries = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-rocket-launch-pad'})) do

      launchpad.register_silo(entity)
    end
  end

  global.has_opened_every_silo = false
end

function launchpad.on_configuration_changed()
  global.has_opened_every_silo = false
  global.deathrattles = nil
end

function launchpad.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination

  launchpad.register_silo(entity)
end

function launchpad.register_silo(entity)
  global.entries[entity.unit_number] = {
    unit_number = entity.unit_number,
    container = entity,
    label = nil,
  }
end

function get_child(parent, name)
  for i = 1,  #parent.children_names do
    if parent.children_names[i] == name then
      return parent.children[i]
    end
  end

  error('could not find a child named ['.. name ..'].')
end

-- remove leading whitespace from string.
function ltrim(s)
  return (s:gsub("^%s*", ""))
end

function remove_rich_text(s)
  local words = {}

  -- split at each space
  for word in s:gmatch("%S+") do
    if word:sub(1, 1) == '[' or word:sub(-1, -1) == ']' then
      -- ignore
    else
      table.insert(words, word)
    end
  end

  return table.concat(words, ' ')
end

function launchpad.on_gui_opened(event)
  if not event.entity then return end
  if event.entity.name ~= 'se-rocket-launch-pad' then return end

  local player = game.get_player(event.player_index)

  -- after an update, have a player open every silo so we can get all fresh values
  if not global.has_opened_every_silo then
    global.has_opened_every_silo = true

    local shifu = player.opened
    player.opened = nil -- or else it fails to open this silo if its either the only or first entry
    for _, entry in pairs(global.entries) do
      if entry.container.valid then
        player.opened = entry.container
      else
        global.entries[_] = nil
      end
    end
    player.opened = shifu
  else
    local container = get_child(player.gui.relative, 'se-rocket-launch-pad-gui')
    local launchpad_gui_frame = container.children[2] -- style = inside_shallow_frame
    local launchpad_gui_inner = get_child(launchpad_gui_frame, 'launchpad_gui_inner')

    local zones_dropdown = get_child(launchpad_gui_inner, 'launchpad-list-zones')
    local destination_text = launchpad.get_destination(zones_dropdown)

    local landingpads_dropdown = get_child(launchpad_gui_inner, 'launchpad-list-landing-pad-names')
    local position_text = launchpad.get_position(landingpads_dropdown)

    launchpad.update_by_unit_number(event.entity.unit_number, destination_text or "Any landing pad with name", position_text or "None - General vicinity")
  end
end

function launchpad.on_gui_selection_state_changed(event)
  if event.element.name == 'launchpad-list-zones' then
    local unit_number = event.element.parent.parent.parent.tags.unit_number
    if not unit_number then error('could not get this silo\'s unit number.') end

    launchpad.update_by_unit_number(unit_number, launchpad.get_destination(event.element) or "Any landing pad with name", nil)
  end

  if event.element.name == 'launchpad-list-landing-pad-names' then
    local unit_number = event.element.parent.parent.parent.tags.unit_number
    if not unit_number then error('could not get this silo\'s unit number.') end

    launchpad.update_by_unit_number(unit_number, nil, launchpad.get_position(event.element) or "None - General vicinity")
  end
end

function launchpad.get_destination(zones_dropdown)
  local selected = zones_dropdown.items[zones_dropdown.selected_index]

  if zones_dropdown.selected_index == 1 then return nil end -- ### known locations
  if selected[1] == "space-exploration.any_landing_pad_with_name" then selected = nil end

  -- "        [img=virtual-signal/se-planet-orbit] Nauvis Orbit"
  if selected ~= nil then selected = ltrim(selected) end
  if selected ~= nil then
    local zone = remote.call("space-exploration", "get_zone_from_name", {zone_name = remove_rich_text(selected)})
    if zone then -- or else fallback to what is selected, like if you select a spaceship as destination (why tho)
      selected = Zone._get_rich_text_name(zone)
    end
  end

  return selected
end

function launchpad.get_position(landingpads_dropdown)
  local selected = landingpads_dropdown.items[landingpads_dropdown.selected_index]

  if selected[1] == "space-exploration.none_general_vicinity" then selected = nil end

  return selected
end

function launchpad.update_by_unit_number(unit_number, destination, position)
  local entry = global.entries[unit_number]

  if destination then
    if entry.destination_id == nil then
      entry.destination_id = rendering.draw_text{
        text = destination,
        color = {1, 1, 1, 1},
        surface = entry.container.surface,
        position = entry.container.position,
        target = entry.container,
        target_offset = {0, 1.55},
        alignment = 'center',
        use_rich_text = true,
        -- scale_with_zoom = true,
      }
    else
      rendering.set_text(entry.destination_id, destination)
    end
  end

  if position then
    if entry.position_id == nil then
      entry.position_id = rendering.draw_text{
        text = position,
        color = {1, 1, 1, 1},
        surface = entry.container.surface,
        position = entry.container.position,
        target = entry.container,
        target_offset = {0, 2.25},
        alignment = 'center',
        use_rich_text = true,
        -- scale_with_zoom = true,
      }
    else
      rendering.set_text(entry.position_id, position)
    end
  end
end

return launchpad
