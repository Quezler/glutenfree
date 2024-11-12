local Combinator = {}

-- this code looks horrid, is probably a bit slow, but hey it works.
-- here are the requirements in case you want to give improving it a go:
-- 1) it must match the ingame visualization
-- 2) there should be a "belt tile count", this includes the underground gap
-- 3) linked belts just count as 2 (just like 2 belts or 2 back-to-back undergrounds)
-- 4) we do not care about partial tiles, like the line starting or stopping on a splitter
-- 5) we only care about transport belts, underground belts, and linked belts
-- 6) linked belts are low priority, and the 1x1 and 1x2 splitters even less

local function get_underground_distance(a, b)
  -- assume there is either a x or y difference, never both
  return math.abs(a.position.x - b.position.x) + math.abs(a.position.y - b.position.y)
end

local function get_transport_line_forward(previous_direction, belt, data)
  if data.belts[assert(belt.unit_number)] then return end

  local inputs = belt.belt_neighbours.inputs
  if #inputs ~= 1 and belt.direction ~= previous_direction then return end

  data.total = data.total + 1
  data.belts[belt.unit_number] = belt

  if belt.type == "underground-belt" and belt.belt_to_ground_type == "input" then
    local other_end = belt.neighbours
    if other_end then
      data.total = data.total - 1 + get_underground_distance(belt, other_end)
      get_transport_line_forward(belt.direction, other_end, data)
    end
    return
  elseif belt.type == "linked-belt" and belt.linked_belt_type == "input" then
    local other_end = belt.linked_belt_neighbour
    if other_end then
      get_transport_line_forward(other_end.direction, other_end, data)
    end
    return
  end

  local in_front = belt.belt_neighbours.outputs[1]
  if in_front and (in_front.type == "transport-belt" or in_front.type == "underground-belt" or in_front.type == "linked-belt") then
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
      data.total = data.total - 1 + get_underground_distance(belt, other_end)
      get_transport_line_backward(this_direction, other_end, data)
    end
    return
  elseif belt.type == "linked-belt" and belt.linked_belt_type == "output" then
    local other_end = belt.linked_belt_neighbour
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

require("shared")

local function get_transport_line(belt, data)
  get_transport_line_forward(belt.direction, belt, data)
  data.belts[belt.unit_number] = nil -- allow the starting belt to be ran backwards
  data.total = data.total - 1
  get_transport_line_backward(belt.direction, belt, data)

  if debug_mode then
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
end

function Combinator.tick_struct(struct)
  if is_belt_read_holding_all_belts(struct.belt) == false then
    -- game.print("nth 60 delete")
    delete_struct(struct)
  else
    local data = {total = 0, belts = {}}
    get_transport_line(struct.belt, data)
    -- game.print(table_size(data.belts) .. ' ' .. data.total)

    local section = struct.combinator_cb.get_section(1)
    local filter = section.get_slot(1)
    filter.min = data.total
    section.set_slot(1, filter)
  end
end

script.on_nth_tick(600, function(event)
  for struct_id, struct in pairs(storage.structs) do
    Combinator.tick_struct(struct)
  end
end)

return Combinator
