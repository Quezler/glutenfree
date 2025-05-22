concrete_roboport_item =
{
	type = "item",
	name = "concrete-roboport",
	icon = mod_directory .. "/graphics/icons/concrete-roboport.png",
	order = "c[signal]-b[concrete-roboport]",
	place_result = "concrete-roboport",
	stack_size = 10,
	subgroup = "logistic-network",
}

data:extend({concrete_roboport_item})
