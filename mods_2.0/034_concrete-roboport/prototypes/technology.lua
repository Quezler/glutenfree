concrete_roboport_technology = 
{
	type = "technology",
	name = "concrete-roboport",
	icon_size = 256,
	icon = mod_directory .. "/graphics/technology/concrete-roboport.png",
	effects =
	{
		{
			type = "unlock-recipe",
			recipe = "concrete-roboport"
		}
	},
	prerequisites = {"logistic-system"},
	unit =
	{
		count = 250,
		ingredients =
		{
			{"automation-science-pack", 1},
			{"logistic-science-pack", 1},
			{"chemical-science-pack", 1},
			{"utility-science-pack", 1},
		},
		time = 30
	}
}

data:extend({ concrete_roboport_technology })
