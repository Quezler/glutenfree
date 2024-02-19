local receiver = data.raw['reactor']['se-energy-receiver']

local furnace = table.deepcopy(data.raw['furnace']['electric-furnace'])
furnace.name = 'se-energy-receiver-electric-furnace'

furnace.collision_mask = {}
furnace.collision_box = receiver.collision_box
furnace.selection_box = {
  {receiver.selection_box[1][1] + 0.5, receiver.selection_box[1][2] + 0.5},
  {receiver.selection_box[2][1] - 0.5, receiver.selection_box[2][2] - 0.5},
}
furnace.selection_priority = (receiver.selection_priority or 50) +1

data:extend{furnace}
