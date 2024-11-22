-- local function on_event(event, handler)
--   assert(event)
--   assert(handler)

--   script.on_event(event, handler)
-- end

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

local pipe_to_ground_names = {
  ["underground-heat-pipe"] = true,
}

local function string_stars_with(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
end

local underpass_names = {}
for _, entity in pairs(prototypes.entity) do
  if entity.type == "heat-pipe" and string_stars_with(entity.name, "underground-heat-pipe-") then
    underpass_names[entity.name] = entity.name
  end
end

local function get_tile_gap_size(a, b)
  return math.abs(a.position.x - b.position.x) + math.abs(a.position.y - b.position.y) - 1
end

local function get_position_between(a, b)
  return {x = (a.position.x + b.position.x) / 2, y = (a.position.y + b.position.y) / 2}
end

local function get_even_or_odd_position(entity) -- 0 = even, 1 = odd
  return (entity.position.x + entity.position.y) % 2
end

local function bring_heatpipe_to_front(old_entity)
  local new_entity = old_entity.surface.create_entity{
    name = old_entity.name,
    force = old_entity.force,
    position = old_entity.position
  }
  new_entity.temperature = old_entity.temperature
  old_entity.destroy()
  return new_entity
end

local other_mode = {
  single = "duo",
  duo = "single",
}

local function struct_set_mode(struct, mode)
  local entity = struct.pipe_to_ground
  local even_or_odd_string = get_even_or_odd_position(entity) == 0 and "even" or "odd"
  local direction_name = direction_to_name[struct.pipe_to_ground.direction]
  local old_name = string.format("underground-heat-pipe-%s-%s-%s", direction_name, other_mode[mode], even_or_odd_string)
  local new_name = string.format("underground-heat-pipe-%s-%s-%s", direction_name,            mode , even_or_odd_string)

  local old_underground_heat_pipe_direction = struct.underground_heat_pipe_direction
  local new_underground_heat_pipe_direction = entity.surface.create_entity{
    name = new_name,
    force = entity.force,
    position = entity.position,
    fast_replace = true,
  }

  assert(old_underground_heat_pipe_direction.name == old_name, string.format("%s ~= %s", old_underground_heat_pipe_direction.name, old_name))
  new_underground_heat_pipe_direction.temperature = old_underground_heat_pipe_direction.temperature
  old_underground_heat_pipe_direction.destroy()
  struct.underground_heat_pipe_direction = new_underground_heat_pipe_direction
end

local function position_equals_position(a, b)
  return a.x == b.x and a.y == b.y
end

-- local function pairs_yeet_valid_false(t, callback)
--   for k, v in pairs(t) do
--     if v.valid then
--       if callback(k, v) then
--         return
--       end
--     else
--       t[k] = nil
--     end
--   end
-- end

--

local function inflate_surfacedata()
  for _, surface in pairs(game.surfaces) do
    if storage.surfacedata[surface.index] == nil then
      ---@diagnostic disable-next-line: param-type-mismatch, missing-fields
      script.get_event_handler(defines.events.on_surface_created){surface_index = surface.index}
    end
  end
end

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}

  storage.underpasses = {}

  storage.surfacedata = {}
  inflate_surfacedata()
end)

script.on_configuration_changed(function()
  inflate_surfacedata()
end)

script.on_event(defines.events.on_surface_created, function(event)
  storage.surfacedata[event.surface_index] = {
    directional_heat_pipes = {},
  }
end)

script.on_event(defines.events.on_surface_deleted, function(event)
  storage.surfacedata[event.surface_index] = nil
end)

-- when you place an entity with heat connections in between two undergrounds the new entity will connect to the inside of the underground,
-- which ofc is not good since it messes up heat transmission abilities as well as the textures, so we got to trigger those to place anew.
function Handler.on_entity_with_heat_buffer_created(entity)
  local underpasses = entity.surface.find_entities_filtered{
    area = entity.bounding_box,
    name = underpass_names,
  }

  for _, underpass in ipairs(underpasses) do
    local struct = storage.underpasses[underpass.unit_number]
    local new_underpass = bring_heatpipe_to_front(struct.underpass)
    local new_source = bring_heatpipe_to_front(struct.source)
    local new_destination = bring_heatpipe_to_front(struct.destination)
    storage.underpasses[struct.id] = nil
    storage.underpasses[new_underpass.unit_number] = {
      id = new_underpass.unit_number,
      underpass = new_underpass,
      source = new_source,
      destination = new_destination,
    }
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  if pipe_to_ground_names[entity.name] == nil then
    return Handler.on_entity_with_heat_buffer_created(entity)
  end

  local even_or_odd_string = get_even_or_odd_position(event.entity) == 0 and "even" or "odd"

  local underground_heat_pipe_direction = entity.surface.create_entity{
    name = string.format("underground-heat-pipe-%s-%s-%s", direction_to_name[entity.direction], "single", even_or_odd_string),
    force = entity.force,
    position = entity.position,
    fast_replace = true,
  }
  underground_heat_pipe_direction.destructible = false
  underground_heat_pipe_direction.temperature = storage.structs[entity.unit_number] and storage.structs[entity.unit_number].temperature or 15
  -- game.print("get " .. underground_heat_pipe_direction.temperature)

  -- storage.structs[entity.unit_number] = {
  --   id = entity.unit_number,
  --   temperature = 15,
  --   pipe_to_ground = entity,
  --   underground_heat_pipe_direction = underground_heat_pipe_direction,
  -- }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {
    type = "pipe-to-ground",
    surface = entity.surface,
    position = entity.position,
  }

  --

  local other = entity.neighbours[1][1]
  if other == nil then return end

  struct_set_mode(storage.structs[entity.unit_number], "duo")
  struct_set_mode(storage.structs[other.unit_number], "duo")

  local tile_gap_size = get_tile_gap_size(entity, other)
  if tile_gap_size > 0 then
    local zero_padded_length_string = string.format("%02d", tile_gap_size)
    local underpass = entity.surface.create_entity{
      name = string.format("underground-heat-pipe-long-%s-%s", direction_to_axis[entity.direction], zero_padded_length_string),
      force = entity.force,
      position = get_position_between(entity, other)
    }

    storage.underpasses[underpass.unit_number] = {
      id = underpass.unit_number,
      underpass = underpass,
      source = storage.structs[entity.unit_number].underground_heat_pipe_direction,
      destination = storage.structs[other.unit_number].underground_heat_pipe_direction,
    }
  end
end

local filters = {
  {filter = "name", name = "underground-heat-pipe"},

  {filter = "name", name = "heat-pipe"},
  {filter = "name", name = "nuclear-reactor"},
  {filter = "name", name = "heating-tower"},
  {filter = "name", name = "heat-exchanger"},
}

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, filters)
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    -- if struct == nil then return end

    if deathrattle.type == "pipe-to-ground" then
      local surfacedata = storage.surfacedata[deathrattle.surface.index]
      if surfacedata then
        for unit_number, directional_heat_pipe in pairs(surfacedata.directional_heat_pipes) do
          if not directional_heat_pipe.valid then
            surfacedata.directional_heat_pipes[unit_number] = nil
          else
            if position_equals_position(directional_heat_pipe.position, deathrattle.position) then
              directional_heat_pipe.destroy()
            end
          end
        end

        -- pairs_yeet_valid_false(surfacedata.directional_heat_pipes, function(unit_number, directional_heat_pipe)
        
        -- end)

      end
      struct.underground_heat_pipe_direction.destroy()
      storage.structs[struct.id] = nil
    else
      error(serpent.block(deathrattle))
    end

  end
end)

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
