script.on_event(defines.events.on_lua_shortcut, function(event)
  if event.prototype_name == "trolley-problem" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    local track_below_player = get_track_below_player(player)
    if not track_below_player then
      return player.create_local_flying_text{text = "[item=rail] ?", position = player.position}
    end

    local called = 0
    for _, train in pairs(game.train_manager.get_trains{surface = player.surface, force = player.force}) do
      if train_matches_player(train, player) then
        local schedule = {}
        schedule.current = 1
        schedule.records = {}

        if train.schedule then
          schedule = train.schedule
          assert(schedule)

          -- remove any existing temporary station @ top
          if(schedule.records[1].temporary == true) then
            table.remove(schedule.records, 1)
          end
        end

        local record = {}
        record.temporary = true
        record.rail = track_below_player
        record.wait_conditions = {
          {compare_type="or", type = "inactivity", ticks = 60 * 15},
          {compare_type="or", type = "inactivity", ticks = 60 *  5},
          {compare_type="and", type = "passenger_present"},
        }

        table.insert(schedule.records, 1, record)
        train.schedule = schedule
        train.go_to_station(1)
        called = called + 1
      end
    end

    player.create_local_flying_text{text = "[item=locomotive] " .. called, position = player.position}
  end
end
)

function train_matches_player(train, player)
  for _, movers in pairs(train.locomotives) do
    for _, locomotive in pairs(movers) do
      if locomotive.color  then -- locomotive color isn't required
        if identical_color(player.color, locomotive.color) then
          return true
        end
      end
    end
  end
  return false
end

function identical_color(color1, color2)
  -- log(serpent.line({color1, color2}))
  -- log(serpent.line{color1.r == color2.r, color1.g == color2.g, color1.b == color2.b})
  return color1.r == color2.r and color1.g == color2.g and color1.b == color2.b
end

function get_track_below_player(player)
  return player.surface.find_entity("straight-rail", player.position) or player.surface.find_entity("curved-rail-a", player.position) or player.surface.find_entity("curved-rail-b", player.position) or player.surface.find_entity("half-diagonal-rail", player.position)
end
