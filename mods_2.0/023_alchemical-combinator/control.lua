-- local is_alchemical_combinator = {
--   ["alchemical-combinator"] = true,
--   ["alchemical-combinator-active"] = true,
-- }

local Handler = {}

script.on_init(function()
  storage.structs = {}
  storage.entity_that_owns = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  storage.structs[entity.unit_number] = {
    entity = entity,
    entity_active = nil,
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
    {filter = "name", name = "alchemical-combinator"},
  })
end

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
    local struct = storage.structs[selected.unit_number]
    assert(struct)

    local active = selected.surface.create_entity{
      name = "alchemical-combinator-active",
      force = selected.force,
      position = selected.position,
      direction = selected.direction,
      create_build_effect_smoke = false,
    }
    assert(active)

    rendering.draw_sprite{
      sprite = direction_to_sprite[selected.direction],
      surface = selected.surface,
      target = active,
      -- time_to_live = 60,
      render_layer = "higher-object-under",
    }

    struct.entity_active = active
    storage.entity_that_owns[active.unit_number] = selected
    return
  end

  if selected and selected.name == "alchemical-combinator-active" then
    local unit_number = storage.entity_that_owns[selected.unit_number].unit_number
    local struct = storage.structs[unit_number]
    assert(struct)

    player.play_sound{
      path = "alchemical-combinator-charge",
      position = selected.position,
    }
  end

  if event.last_entity and event.last_entity.name == "alchemical-combinator-active" then
    local unit_number = storage.entity_that_owns[event.last_entity.unit_number].unit_number
    local struct = storage.structs[unit_number]
    assert(struct)

    player.play_sound{
      path = "alchemical-combinator-uncharge",
      position = event.last_entity.position,
    }

    event.last_entity.destroy()
    struct.entity_active = nil
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity

  if entity and entity.name == "alchemical-combinator-active" then
    player.opened = assert(storage.entity_that_owns[entity.unit_number])
  end
end)
