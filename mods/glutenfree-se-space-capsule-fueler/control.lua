-- /c game.print(serpent.block( game.player.gui.relative.children[3] ))

function get_child(parent, name)
  for i = 1,  #parent.children_names do
    if parent.children_names[i] == name then
      return parent.children[i]
    end
  end

  error('could not find a child named ['.. name ..'].')
end

function deliver_by_proxy(entity, modules)
  local proxy = entity.surface.find_entity("item-request-proxy", entity.position) -- todo: change for 2.0

  if proxy then
    proxy.item_requests = modules
  else
    entity.surface.create_entity({
      name = "item-request-proxy",
      target = entity,
      modules = modules,
      position = entity.position,
      force = entity.force,
    })
  end
end

function fuel_capsule(entity, current_fuel, required_fuel)

  -- fuel levels have reached their equilibrium :)
  if current_fuel == required_fuel then return end

  -- deliver what is missing
  if required_fuel > current_fuel then
    deliver_by_proxy(entity, {["rocket-fuel"] = required_fuel - current_fuel})
  end

  -- spill what is excess
  if required_fuel < current_fuel then
    local inventory = entity.get_inventory(defines.inventory.chest)
    inventory.remove({name = 'rocket-fuel', count = current_fuel - required_fuel})
    entity.surface.spill_item_stack(entity.position, {name = 'rocket-fuel', count = current_fuel - required_fuel}, false, entity.force, false)
  end
end

script.on_event(defines.events.on_gui_opened, function(event)
  if not event.entity then return end
  if event.entity.name ~= 'se-space-capsule' then return end

  local player = game.get_player(event.player_index)

  -- if the player is in god mode the stacks in their inventory are not taken into account
  if player.character == nil then return end

  local container = get_child(player.gui.relative, 'se-space-capsule-gui')
  local capsule_gui_frame = get_child(container, 'capsule_gui_inner')
  local subheader_frame = capsule_gui_frame.children[1]

  local subheader_child = {
    capacity = 1,
    sections = 2,
    fuel     = 3,
    status   = 4,
  }

  local fuel_label = subheader_frame.children[subheader_child.fuel].children[3] -- [text, spacer, min/max]
  local current_fuel = fuel_label.caption[2]
  local required_fuel = fuel_label.caption[3]

  -- game.print(current_fuel)
  -- game.print(required_fuel)

  fuel_capsule(event.entity, current_fuel, required_fuel)
end)
