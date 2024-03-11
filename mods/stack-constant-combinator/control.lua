local mod = {}

script.on_event(defines.events.on_player_rotated_entity, function(event)
  local entity = event.entity
  if entity.name == 'stack-constant-combinator' then
    entity.surface.find_entity('stack-constant-combinator-internal', entity.position).direction = entity.direction
  end
end)

local function sync_combinator(entity)
  -- assert(entity)
  local combinator = entity.surface.find_entity('stack-constant-combinator-internal', entity.position)
  if combinator == nil then
    combinator = entity.surface.create_entity{
      name = 'stack-constant-combinator-internal',
      force = entity.force,
      position = entity.position,
      direction = entity.direction,
    }

    combinator.destructible = false

    combinator.connect_neighbour({
      target_entity = entity,
      wire = defines.wire_type.red,
    })
    combinator.connect_neighbour({
      target_entity = entity,
      wire = defines.wire_type.green,
    })

    global.deathrattles[script.register_on_entity_destroyed(entity)] = combinator
  end

  local parameters = entity.get_control_behavior().parameters

  for _, parameter in ipairs(parameters) do
    if parameter.signal.name then
      if parameter.signal.type == 'item' then
        parameter.count = (parameter.count * global.stack_size[parameter.signal.name]) - parameter.count
      else
        parameter.count = -parameter.count
      end
    end
  end

  combinator.get_control_behavior().parameters = parameters
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == 'stack-constant-combinator' then
    sync_combinator(entity)
    global.playerdata[event.player_index] = {
      entity = entity,
      player = game.get_player(event.player_index)
    }
    script.on_event(defines.events.on_tick, mod.on_tick)
  end
end)

local function on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  sync_combinator(entity)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'stack-constant-combinator'},
  })
end

local function on_configuration_changed()
  global.playerdata = global.playerdata or {}
  global.deathrattles = global.deathrattles or {}

  global.stack_size = {}
  for _, item_prototype in pairs(game.item_prototypes) do
    global.stack_size[item_prototype.name] = item_prototype.stack_size
  end

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'stack-constant-combinator'})) do
      sync_combinator(entity)
    end
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

function mod.on_tick(event)
  for player_index, playerdata in pairs(global.playerdata) do
    if playerdata.player.valid and playerdata.entity.valid and playerdata.player.opened and playerdata.player.opened == playerdata.entity then
      sync_combinator(playerdata.entity)
    else
      global.playerdata[player_index] = nil
    end
  end

  if table_size(global.playerdata) == 0 then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function(event)
  if table_size(global.playerdata) > 0 then
    script.on_event(defines.events.on_tick, mod.on_tick)
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if event.destination.name == 'stack-constant-combinator' then
    sync_combinator(event.destination)
  end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    deathrattle.destroy()
  end
end)
