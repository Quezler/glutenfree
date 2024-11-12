local function get_transport_line_forward(previous_direction, belt, data)
  if data.belts[assert(belt.unit_number)] then return end

  local inputs = belt.belt_neighbours.inputs
  if #inputs ~= 1 and belt.direction ~= previous_direction then return end

  data.total = data.total + 1
  data.belts[belt.unit_number] = belt

  if belt.type == "underground-belt" and belt.belt_to_ground_type == "input" then
    local other_end = belt.neighbours
    if other_end then
      get_transport_line_forward(belt.direction, other_end, data)
    end
    return
  end

  local in_front = belt.belt_neighbours.outputs[1]
  if in_front and (in_front.type == "transport-belt" or in_front.type == "underground-belt") then
    get_transport_line_forward(belt.direction, in_front, data)
  end
end

local function get_transport_line_backward(next_direction, belt, data)
  if data.belts[assert(belt.unit_number)] then return end

  data.total = data.total + 1
  data.belts[belt.unit_number] = belt

  this_direction = belt.direction
  if belt.type == "transport-belt" then
    if belt.belt_shape == "left" then this_direction = this_direction + 4 end
    if belt.belt_shape == "right" then this_direction = this_direction - 4 end
  elseif belt.type == "underground-belt" and belt.belt_to_ground_type == "output" then
    local other_end = belt.neighbours
    if other_end then
      get_transport_line_backward(this_direction, other_end, data)
    end
    return
  end

  local inputs = belt.belt_neighbours.inputs
  if #inputs == 1 then
    get_transport_line_backward(this_direction, inputs[1], data)
  else
    for _, input in ipairs(inputs) do
      if input.direction == next_direction then
        get_transport_line_backward(this_direction, input, data)
      end
    end
  end
end

local function get_transport_line(belt, data)
  get_transport_line_forward(belt.direction, belt, data)
  data.belts[belt.unit_number] = nil -- allow the starting belt to be ran backwards
  data.total = data.total - 1
  get_transport_line_backward(belt.direction, belt, data)

  for _, found_belt in pairs(data.belts) do
    rendering.draw_circle{
      surface = found_belt.surface,
      target = found_belt.position,
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
      local data = {total = 0, belts = {}}
      get_transport_line(struct.belt, data)
      game.print(table_size(data.belts) .. ' ' .. data.total)
    end
  end
end)
