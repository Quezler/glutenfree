-- local is_alchemical_combinator = {
--   ["alchemical-combinator"] = true,
--   ["alchemical-combinator-active"] = true,
-- }

local Handler = {}

script.on_init(function()
  storage.index = 0
  storage.structs = {}

  storage.alchemical_combinator_to_struct_id = {}
  storage.alchemical_combinator_active_to_struct_id = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  storage.index = storage.index + 1

  storage.structs[storage.index] = {
    -- index = storage.index,
    alchemical_combinator = entity,
    alchemical_combinator_active = nil,

    sprite_render_object = nil,
  }

  storage.alchemical_combinator_to_struct_id[entity.unit_number] = storage.index
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

  if selected and selected.name == "alchemical-combinator" and player.is_cursor_empty() then -- todo: re-select when cursor gets cleared?
    local struct_id = storage.alchemical_combinator_to_struct_id[selected.unit_number]
    assert(struct_id)
    local struct = storage.structs[struct_id]
    assert(struct)

    local active = selected.surface.create_entity{
      name = "alchemical-combinator-active",
      force = selected.force,
      position = selected.position,
      direction = selected.direction,
      create_build_effect_smoke = false,
    }
    assert(active)

    struct.sprite_render_object = rendering.draw_sprite{
      sprite = direction_to_sprite[selected.direction],
      surface = selected.surface,
      target = active,
      -- time_to_live = 60,
      render_layer = "higher-object-under",
    }

    struct.alchemical_combinator_active = active
    storage.alchemical_combinator_active_to_struct_id[active.unit_number] = struct_id
    return
  end

  if selected and selected.name == "alchemical-combinator-active" then
    local struct_id = storage.alchemical_combinator_active_to_struct_id[selected.unit_number]
    assert(struct_id)
    local struct = storage.structs[struct_id]
    assert(struct)

    player.play_sound{
      path = "alchemical-combinator-charge",
      position = selected.position,
    }
  end

  if event.last_entity and event.last_entity.name == "alchemical-combinator-active" then
    local struct_id = storage.alchemical_combinator_active_to_struct_id[event.last_entity.unit_number]
    assert(struct_id)
    local struct = storage.structs[struct_id]
    assert(struct)

    player.play_sound{
      path = "alchemical-combinator-uncharge",
      position = event.last_entity.position,
    }

    event.last_entity.destroy()
    struct.alchemical_combinator_active = nil
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local player = game.get_player(event.player_index)
  local entity = event.entity

  if entity and entity.name == "alchemical-combinator-active" then
    local struct_id = storage.alchemical_combinator_active_to_struct_id[entity.unit_number]
    assert(struct_id)
    local struct = storage.structs[struct_id]
    assert(struct)

    player.opened = struct.entity
  end
end)

require("scripts.trivial-event-handlers")
