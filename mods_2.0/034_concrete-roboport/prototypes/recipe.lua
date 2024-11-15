concrete_roboport_recipe =
{
	type = "recipe",
	name = "concrete-roboport",
	icon = "__concrete-roboport__/graphics/icons/concrete-roboport.png",
	enabled = false,
	energy_required = 10,
	ingredients =
	{
		{type = "item", name = "steel-plate", amount = 10},
		{type = "item", name = "roboport", amount = 1},
		{type = "item", name = "processing-unit", amount = 10},
	},
	results = {{type = "item", name = "concrete-roboport", amount = 1}},
}

data:extend({ concrete_roboport_recipe })
