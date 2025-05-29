concrete_roboport_item =
{
	type = "item",
	name = "concrete-roboport",
	icons = {
		{icon = mod_directory .. "/graphics/icons/concrete-roboport.png"},
		{icon = data.raw["item"]["concrete"].icon, shift = {-8, 8}, scale = 0.25, draw_background = true},
	},
	order = "c[signal]-b[concrete-roboport]",
	place_result = "concrete-roboport",
	stack_size = 10,
	subgroup = "logistic-network",
}

data:extend({concrete_roboport_item})
