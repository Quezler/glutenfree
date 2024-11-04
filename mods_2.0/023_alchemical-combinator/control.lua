-- local is_alchemical_combinator = {
--   ["alchemical-combinator"] = true,
--   ["alchemical-combinator-active"] = true,
-- }

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)
  local selected = player.selected

  if selected and selected.name == "alchemical-combinator" then
    selected.surface.create_entity{
      name = "alchemical-combinator-active",
      force = selected.force,
      -- position = {x = selected.position.x, y = selected.position.y + 0.01},
      position = selected.position,
      direction = selected.direction,
      create_build_effect_smoke = false,
    }
    return
  end

  if selected and selected.name == "alchemical-combinator-active" then
    player.play_sound{
      path = "alchemical-combinator-charge",
      position = selected.position,
    }
  end

  if event.last_entity and event.last_entity.name == "alchemical-combinator-active" then
    player.play_sound{
      path = "alchemical-combinator-uncharge",
      position = event.last_entity.position,
    }
    event.last_entity.destroy()
  end
end)
