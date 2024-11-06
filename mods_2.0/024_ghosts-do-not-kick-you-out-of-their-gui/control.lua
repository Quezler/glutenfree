script.on_init(function()
  storage.playerdata = {} -- player_index to ghost/invalid
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == "entity-ghost" then
    local elevator_music = entity.surface.create_entity{
      name = "ghost-being-configured",
      force = "neutral",
      position = entity.position,
      create_build_effect_smoke = false,
      preserve_ghosts_and_corpses = true,
    }

    if storage.playerdata[event.player_index] then
      storage.playerdata[event.player_index].destroy()
    end

    storage.playerdata[event.player_index] = elevator_music
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if storage.playerdata[event.player_index] then
    storage.playerdata[event.player_index].destroy()
  end
end)

script.on_event(defines.events.on_player_left_game, function(event)
  if storage.playerdata[event.player_index] then
    storage.playerdata[event.player_index].destroy()
  end
end)

script.on_event(defines.events.on_player_removed, function(event)
  if storage.playerdata[event.player_index] then
    storage.playerdata[event.player_index].destroy()
    storage.playerdata[event.player_index] = nil
  end
end)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  event.entity.destroy()
end, {
  {filter = "name", name = "ghost-being-configured"},
})

local function on_created_entity(event)
  error("a \"ghost-being-configured\" entity showed up unexpectedly. booo!")
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = "ghost-being-configured"},
  })
end
