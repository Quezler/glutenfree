-- local is_alchemical_combinator = {
--   ["alchemical-combinator"] = true,
--   ["alchemical-combinator-active"] = true,
-- }

local direction_to_sprite = {
  [defines.direction.north] = "alchemical-combinator-active-north",
  [defines.direction.east ] = "alchemical-combinator-active-east" ,
  [defines.direction.south] = "alchemical-combinator-active-south",
  [defines.direction.west ] = "alchemical-combinator-active-west" ,
}

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)
  local selected = player.selected

  if selected and selected.name == "alchemical-combinator" then
    local active = selected.surface.create_entity{
      name = "alchemical-combinator-active",
      force = selected.force,
      -- position = {x = selected.position.x, y = selected.position.y + 0.01},
      position = selected.position,
      direction = selected.direction,
      create_build_effect_smoke = false,
    }

    rendering.draw_sprite{
      sprite = direction_to_sprite[selected.direction],
      surface = selected.surface,
      target = active,
      -- time_to_live = 60,
      render_layer = "higher-object-under",
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

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity

  if entity and entity.name == "alchemical-combinator-active" then
    player.opened = entity.surface.find_entity("alchemical-combinator", entity.position)
  end
end)
