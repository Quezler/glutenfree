require("shared")

script.on_init(function()
  storage.tasks_at_tick = {}
end)

script.on_configuration_changed(function()
  --
end)

local function add_task_at_tick(tick, task)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then
    tasks_at_tick[#tasks_at_tick + 1] = task
  else
    storage.tasks_at_tick[tick] = {task}
  end
end

local function explicit_surface(surface)
  if type(surface) == "string" then
    return game.get_surface(surface)
  elseif type(surface) == "number" then
    return game.get_surface(surface)
  else
    return surface
  end
end

local function explicit_position(position)
  if position[1] then
    position = {x = position[1], y = position[2]}
  end

  return position
end

local function explicit_area(area)
  if area[1] then
    area = {
      left_top = {x = area[1][1], y = area[1][2]},
      right_bottom = {x = area[2][1], y = area[2][2]},
    }
  end

  return area
end

local function get_tilebox(bounding_box)
  local left_top = {x = math.floor(bounding_box.left_top.x), y = math.floor(bounding_box.left_top.y)}
  local right_bottom = {x = math.ceil(bounding_box.right_bottom.x), y = math.ceil(bounding_box.right_bottom.y)}

  local positions = {}

  for y = left_top.y, right_bottom.y - 1 do
      for x = left_top.x, right_bottom.x - 1 do
          table.insert(positions, {x = x, y = y})
      end
  end

  return positions
end

-- position is expected to have a .5 decimal
local function get_piece(position, center)
  if position.x > center.x then
    return position.y < center.y and "back_right" or "front_right"
  else
    return position.y < center.y and "back_left" or "front_left"
  end
end

local function is_back_piece(piece)
  return piece == "back_left" or piece == "back_right"
end

local function get_manhattan_distance(position, center)
  local delta_x = position.x - center.x
  local delta_y = position.y - center.y

  return math.abs(delta_x) + math.abs(delta_y)
end

local function get_build_sound_path(selection_box)
  local area = (selection_box.right_bottom.x - selection_box.left_top.x) * (selection_box.right_bottom.y - selection_box.left_top.y)

  if area < prototypes.utility_constants.small_area_size  then return "utility/build_animated_small"  end
  if area < prototypes.utility_constants.medium_area_size then return "utility/build_animated_medium" end
  if area < prototypes.utility_constants.large_area_size  then return "utility/build_animated_large"  end

  return "utility/build_animated_huge"
end

local TICKS_PER_FRAME = 2
-- local FRAMES_BEFORE_BUILT = 16
local FRAMES_BETWEEN_BUILDING = 8 * 2
local FRAMES_BETWEEN_REMOVING = 4

function request_platform_animation_for_config(config)
  local tick = game.tick

  local surface = explicit_surface(config.surface)
  local position = explicit_position(config.position)
  local top_render_layer = config.top_render_layer or "higher-object-above"

  local collision_box = explicit_area(config.area)
  local selection_box = explicit_area(config.area)

  surface.play_sound{
    path = get_build_sound_path(selection_box),
    position = position,
  }

  local tilebox = get_tilebox(collision_box)
  local largest_manhattan_distance = 0
  for _, tile in ipairs(tilebox) do
    tile.center = {x = tile.x + 0.5, y = tile.y + 0.5}
    tile.manhattan_distance = math.ceil(get_manhattan_distance(tile.center, position))

    if tile.manhattan_distance > largest_manhattan_distance then
      largest_manhattan_distance = tile.manhattan_distance
    end
  end

  local remove_scaffold_delay = (largest_manhattan_distance + 4) * FRAMES_BETWEEN_BUILDING

  local all_scaffolding_down_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay + 16 * TICKS_PER_FRAME
  local all_scaffolding_up_at = tick + 1 + largest_manhattan_distance * FRAMES_BETWEEN_BUILDING + 15 * TICKS_PER_FRAME

  for _, tile in ipairs(tilebox) do
    local piece = get_piece(tile.center, position)
    local animations = {} -- {top, body}

    local up_base = tick + 1 + tile.manhattan_distance * FRAMES_BETWEEN_BUILDING
    add_task_at_tick(up_base + 00 * TICKS_PER_FRAME, {name = "start", animations = animations})
    add_task_at_tick(up_base + 15 * TICKS_PER_FRAME, {name = "pause", offset = 15, animations = animations})

    local down_base = tick + 1 + tile.manhattan_distance * FRAMES_BETWEEN_REMOVING + remove_scaffold_delay
    add_task_at_tick(down_base + 00 * TICKS_PER_FRAME, {name = "unpause", offset = 16, animations = animations})

    local ttl = down_base - tick + 16 * TICKS_PER_FRAME

    animations[1] = rendering.draw_animation{
      target = tile.center,
      surface = surface,
      animation = mod_prefix .. piece .. "-top",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = top_render_layer,
      visible = false,
    }

    animations[2] = rendering.draw_animation{
      target = tile.center,
      surface = surface,
      animation = mod_prefix .. piece .. "-body",
      time_to_live = ttl,
      animation_offset = 0,
      animation_speed = 0,
      render_layer = is_back_piece(piece) and "lower-object-above-shadow" or "object",
      visible = false,
    }
  end

  return {
    all_scaffolding_up_at = all_scaffolding_up_at,
    all_scaffolding_down_at = all_scaffolding_down_at,
  }
end

local function do_tasks_at_tick(event)
  local tick = event.tick
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then storage.tasks_at_tick[tick] = nil
    for _, task in ipairs(tasks_at_tick) do
      if task.name == "start" then
        local offset = - (tick * 0.5) % 32
        task.animations[1].visible = true
        task.animations[2].visible = true
        task.animations[1].animation_speed = 1
        task.animations[2].animation_speed = 1
        task.animations[1].animation_offset = offset
        task.animations[2].animation_offset = offset
      elseif task.name == "pause" then
        task.animations[1].animation_speed = 0
        task.animations[2].animation_speed = 0
        task.animations[1].animation_offset = task.offset
        task.animations[2].animation_offset = task.offset
      elseif task.name == "unpause" then
        local offset = - (tick * 0.5) % 32
        task.animations[1].animation_speed = 1
        task.animations[2].animation_speed = 1
        task.animations[1].animation_offset = offset + task.offset
        task.animations[2].animation_offset = offset + task.offset
      end
    end
  end
end

script.on_event(defines.events.on_tick, do_tasks_at_tick)

local function interface_create(config)
  return request_platform_animation_for_config(config)
end

local function interface_legacy(entity)
  return interface_create({
    surface = entity.surface,
    position = entity.position, -- must be a position within the area, preferably the center
    area = entity.bounding_box, -- the area of the map that shound be covered by scaffolding

    top_render_layer = get_entity_type(entity) == "cargo-landing-pad" and "above-inserters" or "higher-object-above",
  })
end

-- /c remote.call("space-platform-entity-build-animation-lib", "legacy", game.player.selected)
-- /c remote.call("space-platform-entity-build-animation-lib", "create", {surface = "nauvis", position = {0, 0}, area = {{-2, -2}, {2, 2}}})
-- /c remote.call("space-platform-entity-build-animation-lib", "create", {surface = game.player.surface, position = game.player.position, area = {{-10, -20}, {20, 10}}})
remote.add_interface(mod_name, {
  legacy = interface_legacy,
  create = interface_create,
})
