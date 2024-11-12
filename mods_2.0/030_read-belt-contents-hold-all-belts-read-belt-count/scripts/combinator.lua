-- local function trace_belt(belt)
--   game.print(serpent.line( belt.belt_neighbours ))

--   local in_front = belt.belt_neighbours.output[1]
--   if in_front and in_front.type == "transport-belt" then
--   end
-- end

local function get_next_belt(belt, seen)
  local seen_key = string.format("x%d,y%d", belt.position.x, belt.position.y)
  if seen[seen_key] then return end
  seen[seen_key] = true

  rendering.draw_circle{
    surface = belt.surface,
    target = belt.position,
    radius = 0.1,
    color = {1, 1, 1, 1},
    filled = true,
    time_to_live = 30,
  }

  local in_front = belt.belt_neighbours.outputs[1]
  if in_front and in_front.type == "transport-belt" then
    get_next_belt(in_front, seen)
  end
end

script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if is_belt_read_holding_all_belts(struct.belt) == false then
      game.print("nth 60 delete")
      delete_struct(struct)
    else
      get_next_belt(struct.belt, {})
    end
  end
end)
