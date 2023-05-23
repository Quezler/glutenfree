concrete_roboport_recipe =
{
	type = "recipe",
	name = "concrete-roboport",
	enabled = false,
	energy_required = 10,
	ingredients =
	{
		{ "steel-plate", 10 },
		{ "roboport", 4 },
		{ "processing-unit", 10 }
	},
	result = "concrete-roboport"
}

data:extend({ concrete_roboport_recipe })
