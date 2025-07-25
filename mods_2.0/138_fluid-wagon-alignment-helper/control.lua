require("namespace")

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity

  if entity and entity.type == "fluid-wagon" then
    local tank_count = prototypes.mod_data[mod_prefix .. "tank-count"].get(event.entity.name) or 3
    local surface = entity.surface

    for i = 1, tank_count * 2 do
      rendering.draw_sprite{
        surface = surface,
        sprite = "utility/indication_arrow",
        tint = {1, 1, 1, 0.5},
        orientation = 0.75, -- left
        target = {entity = entity, offset = {-0.7, i - tank_count - 0.5}},
        players = {player},
        only_in_alt_mode = true,
      }
      rendering.draw_sprite{
        surface = surface,
        sprite = "utility/indication_arrow",
        tint = {1, 1, 1, 0.5},
        orientation = 0.25, -- right
        target = {entity = entity, offset = { 0.7, i - tank_count - 0.5}},
        players = {player},
        only_in_alt_mode = true,
      }
    end
  end
end)
