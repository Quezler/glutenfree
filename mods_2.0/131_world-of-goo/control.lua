local function get_random_eye_name()
  -- return "generic-eye-glass-2"
  return "generic-eye-glass-" .. tostring(math.random(1, 3))
end

commands.add_command("goo-balls", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local fishes = player.surface.find_entities_filtered{type = "fish"}
  game.print(#fishes)

  for _, fish in ipairs(fishes) do
    -- rendering.draw_sprite{
    --   surface = fish.surface,
    --   target = fish,
    --   sprite = "goo-ball",
      -- use_target_orientation = true,
      -- orientation_target = fish,
    -- }

    rendering.draw_sprite{
      surface = fish.surface,
      target = {entity = fish},
      sprite = "common-body",
      use_target_orientation = true,
      orientation_target = fish,
    }

    -- rendering.draw_sprite{
    --   surface = fish.surface,
    --   target = {entity = fish, offset = {0, -0.2}},
    --   sprite = get_random_eye_name(),
    --   use_target_orientation = true,
    --   orientation_target = fish,
    --   oriented_offset = {-0.1, 0},
    -- }

    -- rendering.draw_sprite{
    --   surface = fish.surface,
    --   target = {entity = fish, offset = {0, -0.2}},
    --   sprite = get_random_eye_name(),
    --   use_target_orientation = true,
    --   orientation_target = fish,
    --   oriented_offset = { 0.1, 0},
    -- }

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
end)
