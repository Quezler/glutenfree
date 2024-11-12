-- local function trace_belt(belt)
--   game.print(serpent.line( belt.belt_neighbours ))

--   local in_front = belt.belt_neighbours.output[1]
--   if in_front and in_front.type == "transport-belt" then
--   end
-- end

local function get_transport_line_forward(previous_direction, belt, belts)
  if belts[assert(belt.unit_number)] then return end

  local inputs = belt.belt_neighbours.inputs
  if #inputs ~= 1 and belt.direction ~= previous_direction then return end

  belts[belt.unit_number] = belt

  local in_front = belt.belt_neighbours.outputs[1]
  if in_front and in_front.type == "transport-belt" then
    get_transport_line_forward(belt.direction, in_front, belts)
  end
end

local function get_transport_line_backward(next_direction, belt, belts)
  if belts[assert(belt.unit_number)] then return end
  belts[belt.unit_number] = belt

  local inputs = belt.belt_neighbours.inputs
  if #inputs == 1 then
    get_transport_line_backward(belt.direction, inputs[1], belts)
  else
    for _, input in ipairs(inputs) do
      if input.direction == next_direction then
        get_transport_line_backward(belt.direction, input, belts)
      end
    end
  end
end

local function get_transport_line(belt, belts)
  get_transport_line_forward(belt.direction, belt, belts)
  belts[belt.unit_number] = nil -- allow the starting belt to be ran backwards
  get_transport_line_backward(belt.direction, belt, belts)

  for _, belt in pairs(belts) do
    rendering.draw_circle{
      surface = belt.surface,
      target = belt.position,
      radius = 0.1,
      color = {1, 1, 1, 1},
      filled = true,
      time_to_live = 30,
    }
  end
end

script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if is_belt_read_holding_all_belts(struct.belt) == false then
      game.print("nth 60 delete")
      delete_struct(struct)
    else
      local belts = {}
      get_transport_line(struct.belt, belts)
      -- game.print(table_size(belts))
    end
  end
end)
