local launchpad = {}

function launchpad.init()
  global.entries = {}
  global.deathrattles = {}
end

function launchpad.on_configuration_changed()
  --
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
end

function launchpad.get_destination(zones_dropdown)
  local selected = zones_dropdown.items[zones_dropdown.selected_index]

  if selected[1] == "space-exploration.any_landing_pad_with_name" then selected = nil end

  -- "        [img=virtual-signal/se-planet-orbit] Nauvis Orbit"
  if selected ~= nil then selected = ltrim(selected) end

  return selected
end

return launchpad
