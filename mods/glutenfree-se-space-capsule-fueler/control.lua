-- /c game.print(serpent.block( game.player.gui.relative.children[3] ))

function get_child(parent, name)
  for i = 1,  #parent.children_names do
    if parent.children_names[i] == name then
      return parent.children[i]
    end
  end

  error('could not find a child named ['.. name ..'].')
end

script.on_event(defines.events.on_gui_opened, function(event)
  if not event.entity then return end
  if event.entity.name ~= 'se-space-capsule' then return end

  local player = game.get_player(event.player_index)

  -- game.print(event.entity.name)

  -- local 

  -- game.print(serpent.block( player.gui.relative.children_names[3] ))
  -- game.print(serpent.block( player.gui.relative.children[3] ))

  local container = get_child(player.gui.relative, 'se-space-capsule-gui')
  local inner = get_child(container, 'capsule_gui_inner')
  -- inner = get_child(container, 'capsule_gui_inner')
  -- inner = get_child(container, 'capsule_gui_inner')

  -- game.print(serpent.block( container.children_names ))
  -- game.print(serpent.block( inner.children_names ))
  -- game.print(serpent.block( inner.children[1].style.name ))

  local subheader_frame = inner.children[1]
  -- game.print(serpent.block( subheader_frame.children_names ))

  local fuel_index = 2
  local fuel_label = subheader_frame.children[fuel_index].children[3] -- [text, spacer, min/max]
  -- local localized_string, current, required = fuel_label.caption
  
  -- game.print( serpent.block(fuel_label.caption) )
  -- game.print(fuel_label.caption[2])

  local current_fuel = fuel_label.caption[2]
  local required_fuel = fuel_label.caption[3]

  game.print(current_fuel)
  game.print(required_fuel)
end)
