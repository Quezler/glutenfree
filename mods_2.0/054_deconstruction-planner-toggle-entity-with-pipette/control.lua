local mod_prefix = "deconstruction-planner-toggle-entity-with-pipette--"

-- script.on_event(mod_prefix .. "clear-cursor", function(event)
--   game.print(string.format("%d clear cursor", event.tick))
-- end)

script.on_event(mod_prefix .. "pipette", function(event)
  game.print(string.format("%d pipette", event.tick))
end)
