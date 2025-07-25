require("namespace")

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity

  if entity and entity.type == "fluid-wagon" then
    local tank_count = prototypes.mod_data[mod_prefix .. "tank-count"].get(event.entity.name) or 3
    local surface = entity.surface

    for i = 1, tank_count * 2 do
      rendering.draw_circle{
        surface = surface,
        target = {entity = entity, offset = {-0.75, i - 3 - 0.5}},
        color = {1, 1, 0},
        filled = true,
        radius = 0.1,
      }
    end
  end
end)
