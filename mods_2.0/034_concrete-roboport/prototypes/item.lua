concrete_roboport_item =
{
	type = "item",
	name = "concrete-roboport",
	icons = {
		{icon = "__core__/graphics/empty.png", icon_size = 1},
		{icon = mod_directory .. "/graphics/icons/concrete-roboport.png", scale = 0.45, shift = {0, 1.6}},
	},
	order = "c[signal]-b[concrete-roboport]",
	place_result = "concrete-roboport",
	stack_size = 10,
	subgroup = "logistic-network",
}

data:extend({concrete_roboport_item})
