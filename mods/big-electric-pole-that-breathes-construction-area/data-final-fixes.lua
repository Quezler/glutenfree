local big_electric_pole = data.raw['electric-pole']['big-electric-pole']
local roboport          = data.raw['roboport']['big-electric-pole-roboport']

roboport.construction_radius           = big_electric_pole.maximum_wire_distance + 4
roboport.logistics_connection_distance = big_electric_pole.maximum_wire_distance + 4
