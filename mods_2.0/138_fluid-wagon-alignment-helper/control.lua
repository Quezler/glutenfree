require("namespace")

script.on_init(function()
  storage.sprites_for_player = {}
end)

script.on_event(defines.events.on_player_driving_changed_state, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.vehicle

  if entity and entity.type == "fluid-wagon" then
    local tank_count = prototypes.mod_data[mod_prefix .. "tank-count"].get(event.entity.name) or 3
    local surface = entity.surface

    sprites_for_player = {}
    for i = 1, tank_count * 2 do
      for _, config in ipairs({
        {name = "left", orientation = 0.75, oriented_offset_x = -0.7},
        {name = "right", orientation = 0.25, oriented_offset_x = 0.7},
      }) do
        table.insert(sprites_for_player, rendering.draw_sprite{
          surface = surface,
          sprite = "utility/indication_arrow",
          tint = {1, 1, 1, 0.5},
          orientation = config.orientation,
          target = {entity = entity},
          players = {player},
          only_in_alt_mode = true,
          orientation_target = {entity = entity},
          use_target_orientation = true,
          oriented_offset = {config.oriented_offset_x, i - tank_count - 0.5},
        })
      end
    end
    storage.sprites_for_player[player.index] = sprites_for_player
  else
    local sprites_for_player = storage.sprites_for_player[player.index]
    if sprites_for_player then storage.sprites_for_player[player.index] = nil
      for _, sprite in ipairs(sprites_for_player) do
        sprite.destroy()
      end
    end
  end
end)
