local function get_random_eye_name()
  -- return "generic-eye-glass-2"
  return "generic-eye-glass-" .. tostring(math.random(1, 3))
end

local function render_goo_ball(fish)
  rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = "common-body",
  }

  local use_target_orientation = false
  local orientation_target = fish.position

  if math.random() < 0.5 then
    use_target_orientation = true
    orientation_target = fish
  end

  local left_eye = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = get_random_eye_name(),
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = {-0.15, -0.05},
  }

  local right_eye = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = get_random_eye_name(),
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = { 0.15, -0.05},
  }

  local left_pupil = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = "generic-pupil",
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = {-0.15, -0.07},
  }

  local right_pupil = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = "generic-pupil",
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = { 0.15, -0.07},
  }

  -- local unit_number = script.register_on_object_destroyed(fish)
  -- storage.goo_balls[unit_number] = {
  --   entity = fish,

  --   left_eye = left_eye,
  --   right_eye = right_eye,
  --   left_pupil = left_pupil,
  --   right_pupil = right_pupil,
  -- }
end

commands.add_command("goo-balls", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local fishes = player.surface.find_entities_filtered{type = "fish"}
  game.print(#fishes)

  for _, fish in ipairs(fishes) do
    render_goo_ball(fish)
  end
end)

-- does not trigger for the spawning pool, caught by on_init instead, weird right?
script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "goo-ball-created" then return end

  render_goo_ball(event.source_entity)
end)

script.on_init(function()
  storage.goo_balls = {}
  storage.goo_balls_next = nil

  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = "goo-ball"}) do
      render_goo_ball(entity) -- probably only nauvis
    end
  end
end)

-- script.on_event(defines.events.on_tick, function()
--   local unit_number, struct = next(storage.goo_balls, storage.goo_balls_next)
--   storage.goo_balls_next = unit_number

--   if struct then
--     if not struct.entity.valid then
--       storage.goo_balls[unit_number] = nil
--     else
--       local entities = struct.entity.surface.find_entities_filtered{
--         position = struct.entity.position,
--         range = 5,
--       }
--       local entity = entities[math.random(1, #entities)] -- should always contain at least one: itself
--       struct.left_eye.orientation_target = entity
--       struct.right_eye.orientation_target = entity
--       struct.left_pupil.orientation_target = entity
--       struct.right_pupil.orientation_target = entity
--     end
--   end
-- end)
