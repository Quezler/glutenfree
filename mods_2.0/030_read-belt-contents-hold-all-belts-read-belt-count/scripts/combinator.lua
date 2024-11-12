-- local function trace_belt(belt)
--   game.print(serpent.line( belt.belt_neighbours ))

--   local in_front = belt.belt_neighbours.output[1]
--   if in_front and in_front.type == "transport-belt" then
--   end
-- end

local function get_next_belt(belt, belts)
  if belts[assert(belt.unit_number)] then return end
  belts[belt.unit_number] = belt

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
    get_next_belt(in_front, belts)
  end
end

script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if is_belt_read_holding_all_belts(struct.belt) == false then
      game.print("nth 60 delete")
      delete_struct(struct)
    else
      local belts = {}
      get_next_belt(struct.belt, belts)
      game.print(table_size(belts))
    end
  end
end)
