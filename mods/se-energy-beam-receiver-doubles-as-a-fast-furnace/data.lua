local receiver = data.raw['reactor']['se-energy-receiver']

local furnace = table.deepcopy(data.raw['furnace']['electric-furnace'])
furnace.name = 'se-energy-receiver-electric-furnace'
furnace.localised_name = {'entity-name.' .. receiver.name}

furnace.icon = receiver.icon
furnace.icon_size = receiver.icon_size

furnace.collision_mask = {}
furnace.collision_box = {
  {receiver.collision_box[1][1], receiver.collision_box[1][2] + 2.5},
  {receiver.collision_box[2][1], receiver.collision_box[2][2] + 2.5},
}

furnace.selection_box = {
  {receiver.selection_box[1][1] + 0.5, receiver.selection_box[1][2] + 0.5 + 2.5},
  {receiver.selection_box[2][1] - 0.5, receiver.selection_box[2][2] - 0.5 + 2.5},
}

furnace.selection_priority = (receiver.selection_priority or 50) + 1
furnace.scale_entity_info_icon = true
table.insert(furnace.flags, 'placeable-off-grid')

data:extend{furnace}
