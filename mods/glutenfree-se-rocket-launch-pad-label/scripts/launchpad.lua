local launchpad = {}

function launchpad.init()
  global.entries = {}
  global.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-rocket-launch-pad'})) do

      launchpad.register_silo(entity)
    end
  end
end

function launchpad.on_configuration_changed()
  --
end

function launchpad.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'se-rocket-launch-pad' then return end

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

function launchpad.on_gui_opened(event)
  if not event.entity then return end
  if event.entity.name ~= 'se-rocket-launch-pad' then return end

  local player = game.get_player(event.player_index)

  local container = get_child(player.gui.relative, 'se-rocket-launch-pad-gui')
  local launchpad_gui_frame = container.children[2] -- style = inside_shallow_frame
  local launchpad_gui_inner = get_child(launchpad_gui_frame, 'launchpad_gui_inner')

  local zones_dropdown = get_child(launchpad_gui_inner, 'launchpad-list-zones')
  local selected = launchpad.get_destination(zones_dropdown)

  print(serpent.block( selected ))
  game.print(serpent.block( selected ))
end

function launchpad.on_gui_selection_state_changed(event)
  if event.element.name ~= 'launchpad-list-zones' then return end

  local unit_number = event.element.parent.parent.parent.tags.unit_number
  if not unit_number then error('could not get this silo\'s unit number.') end

  game.print(serpent.block( unit_number ))
  game.print(serpent.block( launchpad.get_destination(event.element) ))

  launchpad.update_by_unit_number(unit_number, launchpad.get_destination(event.element))
end

function launchpad.get_destination(zones_dropdown)
  local selected = zones_dropdown.items[zones_dropdown.selected_index]

  if selected[1] == "space-exploration.any_landing_pad_with_name" then selected = nil end

  -- "        [img=virtual-signal/se-planet-orbit] Nauvis Orbit"
  if selected ~= nil then selected = ltrim(selected) end

  return selected
end

function launchpad.update_by_unit_number(unit_number, destination)
  local entry = global.entries[unit_number]

  if entry.label then
    entry.label.destroy()
    entry.label = nil
  end

  if destination == nil then return end

  -- entry.label = rendering.draw_text({
  --   text = destination,
  --   color = {1, 1, 1},
  --   surface = entry.container.surface,
  --   target = entry.container,
  --   target_offset = {0, 1.6},
  --   alignment = 'center',
  -- })

  local position = entry.container.position
  position.y = position.y + 1.9

  entry.label = entry.container.surface.create_entity{name = 'hovering-text', position = position, text = destination}
  global.deathrattles[script.register_on_entity_destroyed(entry.container)] = {entry.label}
end

function launchpad.on_entity_destroyed(event)
  if not global.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(global.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  global.deathrattles[event.registration_number] = nil
end

return launchpad
