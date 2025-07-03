local function get_random_eye_name()
  -- return "generic-eye-glass-2"
  return "generic-eye-glass-" .. tostring(math.random(1, 3))
end

local function render_goo_ball(fish)
  rendering.draw_sprite{
    surface = fish.surface,
    target = {entity = fish},
    sprite = "common-body",
  }

  rendering.draw_sprite{
    surface = fish.surface,
    target = {entity = fish},
    sprite = get_random_eye_name(),
    use_target_orientation = true,
    orientation_target = fish,
    oriented_offset = {-0.15, -0.05},
  }

  rendering.draw_sprite{
    surface = fish.surface,
    target = {entity = fish},
    sprite = get_random_eye_name(),
    use_target_orientation = true,
    orientation_target = fish,
    oriented_offset = { 0.15, -0.05},
  }

  rendering.draw_sprite{
    surface = fish.surface,
    target = {entity = fish},
    sprite = "generic-pupil",
    use_target_orientation = true,
    orientation_target = fish,
    oriented_offset = {-0.15, -0.07},
  }

  rendering.draw_sprite{
    surface = fish.surface,
    target = {entity = fish},
    sprite = "generic-pupil",
    use_target_orientation = true,
    orientation_target = fish,
    oriented_offset = { 0.15, -0.07},
  }
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
  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = "goo-ball"}) do
      render_goo_ball(entity) -- probably only nauvis
    end
  end
end)
