local Handler = {}

local direction_to_axis = {
  [defines.direction.north] = "vertical",
  [defines.direction.south] = "vertical",
  [defines.direction.east] = "horizontal",
  [defines.direction.west] = "horizontal",
}

local direction_to_name = {
  [defines.direction.north] = "north",
  [defines.direction.south] = "south",
  [defines.direction.east] = "east",
  [defines.direction.west] = "west",
}

local function get_tile_distance_inclusive(a, b)
  return math.abs(a.position.x - b.position.x) + math.abs(a.position.y - b.position.y) + 1
end

local function get_position_between(a, b)
  return {x = (a.position.x + b.position.x) / 2, y = (a.position.y + b.position.y) / 2}
end

local function get_even_or_odd_position(entity) -- 0 = even, 1 = odd
  return (entity.position.x + entity.position.y) % 2
end

-- local other_mode = {
--   single = "duo",
--   duo = "single",
-- }

-- local function struct_set_mode(struct, mode)
--   local entity = struct.pipe_to_ground
--   local even_or_odd_string = get_even_or_odd_position(entity) == 0 and "even" or "odd"
--   local direction_name = direction_to_name[struct.pipe_to_ground.direction]
--   local old_name = string.format("underground-heat-pipe-%s-%s-%s", direction_name, other_mode[mode], even_or_odd_string)
--   local new_name = string.format("underground-heat-pipe-%s-%s-%s", direction_name,            mode , even_or_odd_string)

--   local old_underground_heat_pipe_direction = struct.underground_heat_pipe_direction
--   local new_underground_heat_pipe_direction = entity.surface.create_entity{
--     name = new_name,
--     force = entity.force,
--     position = entity.position,
--     fast_replace = true,
--   }

--   assert(old_underground_heat_pipe_direction.name == old_name, string.format("%s ~= %s", old_underground_heat_pipe_direction.name, old_name))
--   new_underground_heat_pipe_direction.temperature = old_underground_heat_pipe_direction.temperature
--   old_underground_heat_pipe_direction.destroy()
--   struct.underground_heat_pipe_direction = new_underground_heat_pipe_direction
-- end

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local even_or_odd_string = get_even_or_odd_position(event.entity) == 0 and "even" or "odd"

  local underground_heat_pipe_direction = entity.surface.create_entity{
    name = string.format("underground-heat-pipe-%s-%s", direction_to_name[entity.direction], even_or_odd_string),
    force = entity.force,
    position = entity.position,
    fast_replace = true,
  }
  underground_heat_pipe_direction.destructible = false
  underground_heat_pipe_direction.temperature = storage.structs[entity.unit_number] and storage.structs[entity.unit_number].temperature or 15
  -- game.print("get " .. underground_heat_pipe_direction.temperature)

  storage.structs[entity.unit_number] = {
    id = entity.unit_number,
    temperature = 15,
    pipe_to_ground = entity,
    underground_heat_pipe_direction = underground_heat_pipe_direction,
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {type = "pipe-to-ground", struct_id = entity.unit_number}

  --

  local other = entity.neighbours[1][1]
  if other == nil then return end

  local tile_distance_inclusive = get_tile_distance_inclusive(entity, other)
  local zero_padded_length_string = string.format("%02d", tile_distance_inclusive)
  entity.surface.create_entity{
    name = string.format("underground-heat-pipe-long-%s-%s", direction_to_axis[entity.direction], zero_padded_length_string),
    force = entity.force,
    position = get_position_between(entity, other)
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "underground-heat-pipe"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    -- if struct == nil then return end

    if deathrattle.type == "pipe-to-ground" then
      struct.underground_heat_pipe_direction.destroy()
      storage.structs[struct.id] = nil
    else
      error(serpent.block(deathrattle))
    end

  end
end)

local pipe_to_ground_names = {
  ["underground-heat-pipe"] = true,
}

script.on_event(defines.events.on_player_rotated_entity, function(event)
  local entity = event.entity
  if pipe_to_ground_names[entity.name] then
    local struct = storage.structs[entity.unit_number]
    struct.temperature = struct.underground_heat_pipe_direction.temperature
    -- game.print("set " .. struct.temperature)
    local old = struct.underground_heat_pipe_direction
    Handler.on_created_entity(event)
    old.destroy()
  end
end)
