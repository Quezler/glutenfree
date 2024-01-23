local infinity_pipes = {
  {
    name = 'infinity-pipe-drilling-mud-1',
    offset = { 0,  6},
  },
  {
    name = 'infinity-pipe-drilling-mud-2',
    offset = {-6,  0},
  },
  {
    name = 'infinity-pipe-drilling-mud-3',
    offset = { 0, -6},
  },
  {
    name = 'infinity-pipe-drilling-mud-4',
    offset = { 6,  0},
  },
}

local function on_created_entity(event)
  local entity = event.created_entity or event.entity

  for i, infinity_pipe in ipairs(infinity_pipes) do
    local position = {entity.position.x + infinity_pipe.offset[1], entity.position.y + infinity_pipe.offset[2]}

    local pipe = entity.surface.find_entity(infinity_pipe.name, position)
    if pipe == nil then
      local placable = entity.surface.can_place_entity{
        name = infinity_pipe.name,
        force = entity.force,
        position = position,
      }

      if placable == false then goto continue end

      pipe = entity.surface.create_entity{
        name = infinity_pipe.name,
        force = entity.force,
        position = position,
      }

      local registration_number = script.register_on_entity_destroyed(entity)
      global.deathrattles[registration_number] = global.deathrattles[registration_number] or {}
      table.insert(global.deathrattles[registration_number], pipe)
    end

    pipe.set_infinity_pipe_filter({
      name = 'se-core-miner-drill-drilling-mud',
      percentage = 1,
      temperature = 100,
    })

    ::continue::
  end

end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-core-miner-drill'},
  })
end

local function on_configuration_changed(event)
  global.deathrattles = global.deathrattles or {}
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

local function on_entity_destroyed(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    for _, entity in ipairs(deathrattle) do
      entity.destroy()
    end
  end
end

script.on_event(defines.events.on_entity_destroyed, on_entity_destroyed)
