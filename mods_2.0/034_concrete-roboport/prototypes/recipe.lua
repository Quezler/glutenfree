concrete_roboport_recipe =
{
	type = "recipe",
	name = "concrete-roboport",
	icon = mod_directory .. "/graphics/icons/concrete-roboport.png",
	enabled = false,
	energy_required = 10,
	ingredients =
	{
		{type = "item", name = "roboport", amount = 1},
		{type = "item", name = "concrete", amount = 20},
	},
	results = {{type = "item", name = "concrete-roboport", amount = 1}},
}

data:extend({ concrete_roboport_recipe })
