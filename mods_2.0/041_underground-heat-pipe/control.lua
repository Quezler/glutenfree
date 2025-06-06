-- local function on_event(event, handler)
--   assert(event)
--   assert(handler)

--   script.on_event(event, handler)
-- end

require("util")

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
  ["fast-underground-heat-pipe"] = true,
  ["express-underground-heat-pipe"] = true,
  ["turbo-underground-heat-pipe"] = true,
  ["supersonic-underground-heat-pipe"] = true,
}

local function string_stars_with(str, prefix)
  return string.sub(str, 1, #prefix) == prefix
end

local underpass_names = {}
for _, entity in pairs(prototypes.entity) do
  if entity.type == "heat-pipe" and string_stars_with(entity.name, "underground-heat-pipe-long-") then
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

local function bring_heatpipe_to_front(old_entity, new_name)
  local new_entity = old_entity.surface.create_entity{
    name = new_name and new_name or old_entity.name,
    force = old_entity.force,
    position = old_entity.position
  }
  new_entity.temperature = old_entity.temperature
  new_entity.destructible = false

  local surfacedata = storage.surfacedata[old_entity.surface.index]
  surfacedata.directional_heat_pipes[util.positiontostr(old_entity.position)] = new_entity

  old_entity.destroy()
  return new_entity
end

local other_mode = {
  single = "duo",
  duo = "single",
}

function Handler.pipe_to_ground_struct_set_mode(struct, mode)
  assert(struct.mode == other_mode[mode])
  struct.mode = mode

  -- game.print(struct.entity.unit_number)
  -- game.print(util.positiontostr(struct.entity.position))

  Handler.pipe_to_ground_struct_recreate_directional_heatpipe(struct)
end

function Handler.pipe_to_ground_struct_recreate_directional_heatpipe(struct)
  local surfacedata = storage.surfacedata[struct.entity.surface.index]

  local key = struct.id -- "[x, y]"
  local old_directional_heatpipe = surfacedata.directional_heat_pipes[key]

  local name = string.format(struct.entity.name .. "-%s-%s-%s", direction_to_name[struct.direction], struct.mode, struct.even_or_odd)
  local new_directional_heatpipe = struct.entity.surface.create_entity{
    name = name,
    force = struct.entity.force,
    position = struct.entity.position,
  }
  new_directional_heatpipe.destructible = false

  if old_directional_heatpipe then
    new_directional_heatpipe.temperature = old_directional_heatpipe.temperature
    old_directional_heatpipe.destroy()
  end

  surfacedata.directional_heat_pipes[key] = new_directional_heatpipe
  return new_directional_heatpipe
end

local function position_equals_position(a, b)
  return a.x == b.x and a.y == b.y
end

local function nil_invalid_entities(t)
  for k, entity in pairs(t) do
    if entity.valid == false then
      t[k] = nil
    end
  end

  return t
end

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
  storage.deathrattles = {}
  storage.surfacedata = {}
  inflate_surfacedata()
  Handler.update_all_force_recipe_visibility()
end)

script.on_configuration_changed(function()
  inflate_surfacedata()
  Handler.update_all_force_recipe_visibility()

  for _, surfacedata in pairs(storage.surfacedata) do
    Handler.update_mode_for_all_pipe_to_grounds(surfacedata)
    Handler.validate_all_underpasses(surfacedata)
  end
end)

script.on_event(defines.events.on_surface_created, function(event)
  storage.surfacedata[event.surface_index] = {
    underpasses = {},
    pipe_to_grounds = {},
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

  local surfacedata = storage.surfacedata[entity.surface.index]

  for _, underpass in ipairs(underpasses) do
    local struct = surfacedata.underpasses[underpass.unit_number]
    local new_underpass = bring_heatpipe_to_front(struct.underpass)
    bring_heatpipe_to_front(surfacedata.directional_heat_pipes[util.positiontostr(struct.source_position)])
    bring_heatpipe_to_front(surfacedata.directional_heat_pipes[util.positiontostr(struct.destination_position)])
    surfacedata.underpasses[struct.id] = nil
    surfacedata.underpasses[new_underpass.unit_number] = {
      id = new_underpass.unit_number,
      underpass = new_underpass,
      source_position = struct.source_position,
      source_direction = struct.source_direction,
      destination_position = struct.destination_position,
      destination_direction = struct.destination_direction,
    }
  end
end

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  if pipe_to_ground_names[entity.name] == nil then
    return Handler.on_entity_with_heat_buffer_created(entity)
  end

  local surfacedata = storage.surfacedata[entity.surface.index]
  local struct_id = util.positiontostr(entity.position)

  -- was a new rotation built over this or did the quality change?
  local old_struct = surfacedata.pipe_to_grounds[struct_id]
  if old_struct then
    surfacedata.pipe_to_grounds[struct_id] = nil
  end

  local struct = new_struct(surfacedata.pipe_to_grounds, {
    id = struct_id,
    entity = entity,
    position = entity.position,
    direction = entity.direction,
    even_or_odd = get_even_or_odd_position(event.entity) == 0 and "even" or "odd",
    mode = "single",
  })

  new_struct(storage.deathrattles, {
    id = script.register_on_object_destroyed(entity),
    type = "pipe-to-ground",
    surface = entity.surface,
    position = entity.position,
  })

  Handler.pipe_to_ground_struct_recreate_directional_heatpipe(struct)
  Handler.update_mode_for_all_pipe_to_grounds(surfacedata)
  Handler.validate_all_underpasses(surfacedata)
end

local function pipe_to_ground_to_struct(pipe_to_ground)
  local surfacedata = storage.surfacedata[pipe_to_ground.surface.index]
  return surfacedata.pipe_to_grounds[util.positiontostr(pipe_to_ground.position)]
end

local function pipe_to_ground_to_directional_heatpipe(pipe_to_ground)
  local surfacedata = storage.surfacedata[pipe_to_ground.surface.index]
  return surfacedata.directional_heat_pipes[util.positiontostr(pipe_to_ground.position)]
end

function Handler.check_for_neighbours(pipe_to_ground_struct)
  local entity = pipe_to_ground_struct.entity
  local other = pipe_to_ground_struct.entity.neighbours[1][1]
  if other == nil then
    if pipe_to_ground_struct.mode == "duo" then
      Handler.pipe_to_ground_struct_set_mode(pipe_to_ground_struct, "single")
    end
    return
  else
    if pipe_to_ground_struct.mode == "single" then
      Handler.pipe_to_ground_struct_set_mode(pipe_to_ground_struct, "duo")
    end
  end

  local tile_gap_size = get_tile_gap_size(entity, other)
  if tile_gap_size > 0 then
    local zero_padded_length_string = string.format("%02d", tile_gap_size)
    local underpass_position = get_position_between(entity, other)
    local underpass_name = string.format("underground-heat-pipe-long-%s-%s", direction_to_axis[entity.direction], zero_padded_length_string)
    local underpass_exists = entity.surface.find_entity(underpass_name, underpass_position) ~= nil
    if not underpass_exists then
      local underpass = entity.surface.create_entity{
        name = underpass_name,
        force = entity.force,
        position = underpass_position,
      }

      local surfacedata = storage.surfacedata[entity.surface.index]

      surfacedata.underpasses[underpass.unit_number] = {
        id = underpass.unit_number,
        underpass = underpass,
        source_position = entity.position,
        source_direction = entity.direction,
        destination_position = other.position,
        destination_direction = other.direction,
      }

      bring_heatpipe_to_front(pipe_to_ground_to_directional_heatpipe(entity))
      bring_heatpipe_to_front(pipe_to_ground_to_directional_heatpipe(other))
    end
  end
end

-- will get a bit nuts once you have thousands of them on a surface and spam blueprints containing several, but who'd be that crazy?
function Handler.update_mode_for_all_pipe_to_grounds(surfacedata)
  for _, pipe_to_ground_struct in pairs(surfacedata.pipe_to_grounds) do
    if pipe_to_ground_struct.entity.valid then
      Handler.check_for_neighbours(pipe_to_ground_struct)
    end
  end
end

function Handler.validate_all_underpasses(surfacedata)
  for underpass_id, underpass in pairs(surfacedata.underpasses) do
    local      source_pipe_to_ground = surfacedata.pipe_to_grounds[util.positiontostr(underpass.source_position)]
    local destination_pipe_to_ground = surfacedata.pipe_to_grounds[util.positiontostr(underpass.destination_position)]

    if source_pipe_to_ground and destination_pipe_to_ground then
      if source_pipe_to_ground.direction == underpass.source_direction and destination_pipe_to_ground.direction == underpass.destination_direction then
        goto continue
      end
    end

    underpass.underpass.destroy()
    surfacedata.underpasses[underpass_id] = nil

    ::continue::
  end
end

local filters = {
  {filter = "name", name = "underground-heat-pipe"},
  {filter = "name", name = "fast-underground-heat-pipe"},
  {filter = "name", name = "express-underground-heat-pipe"},
  {filter = "name", name = "turbo-underground-heat-pipe"},
  {filter = "name", name = "supersonic-underground-heat-pipe"},

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

    if deathrattle.type == "pipe-to-ground" then
      if deathrattle.surface.valid then
        local surfacedata = storage.surfacedata[deathrattle.surface.index]
        local key = util.positiontostr(deathrattle.position)
        if surfacedata.pipe_to_grounds[key].entity.valid == false then -- skip if the position key already got reused for a valid entity
          local directional_heat_pipe = surfacedata.directional_heat_pipes[key]
          directional_heat_pipe.destroy()
          surfacedata.directional_heat_pipes[key] = nil
          surfacedata.pipe_to_grounds[key] = nil
        end

        Handler.update_mode_for_all_pipe_to_grounds(surfacedata)
        Handler.validate_all_underpasses(surfacedata)
      end
    else
      error(serpent.block(deathrattle))
    end

  end
end)

script.on_event(defines.events.on_player_rotated_entity, function(event)
  local entity = event.entity
  if pipe_to_ground_names[entity.name] then
    local surfacedata = storage.surfacedata[entity.surface.index]
    local pipe_to_ground_struct = pipe_to_ground_to_struct(entity)

    pipe_to_ground_struct.direction = entity.direction
    Handler.pipe_to_ground_struct_recreate_directional_heatpipe(pipe_to_ground_struct)
    Handler.update_mode_for_all_pipe_to_grounds(surfacedata)
    Handler.validate_all_underpasses(surfacedata)
  end
end)

local pipe_to_ground_to_underground_belt_map = {
               ["underground-heat-pipe"] =            "underground-belt",
          ["fast-underground-heat-pipe"] =       "fast-underground-belt",
       ["express-underground-heat-pipe"] =    "express-underground-belt",
         ["turbo-underground-heat-pipe"] =      "turbo-underground-belt",
    ["supersonic-underground-heat-pipe"] = "supersonic-underground-belt",
}

function Handler.update_one_force_recipe_visibility(event)
  local force = event.force or event.research.force

  local heat_pipe_enabled = force.recipes["heat-pipe"].enabled

  for pipe_to_ground_name, underground_belt_name in pairs(pipe_to_ground_to_underground_belt_map) do
    if force.recipes[pipe_to_ground_name] then
      force.recipes[pipe_to_ground_name].enabled = heat_pipe_enabled and force.recipes[underground_belt_name].enabled

      -- https://mods.factorio.com/mod/underground-heat-pipe/discussion/683c0c411ef76c3df9937a8e
      if event.name ~= defines.events.on_research_finished then
        for _, player in ipairs(force.players) do
          player.clear_recipe_notification(pipe_to_ground_name)
        end
      end
    end
  end
end

function Handler.update_all_force_recipe_visibility()
  for _, force in pairs(game.forces) do
    Handler.update_one_force_recipe_visibility({force = force})
  end
end

script.on_event(defines.events.on_research_finished, Handler.update_one_force_recipe_visibility)
script.on_event(defines.events.on_research_reversed, Handler.update_one_force_recipe_visibility)
script.on_event(defines.events.on_technology_effects_reset, Handler.update_one_force_recipe_visibility)
