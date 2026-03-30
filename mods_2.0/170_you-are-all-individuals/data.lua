local unit_group = data.raw["map-settings"]["map-settings"].unit_group
unit_group.max_gathering_unit_groups = unit_group.max_gathering_unit_groups * unit_group.max_unit_group_size -- default: 30
unit_group.min_group_gathering_time = unit_group.min_group_gathering_time / unit_group.max_unit_group_size -- default: 3600
unit_group.max_group_gathering_time = unit_group.max_group_gathering_time / unit_group.max_unit_group_size -- default: 10 * 3600
unit_group.max_unit_group_size = 1 -- default: 200
