concrete_roboport_item = 		
{
	type = "item",
	name = "concrete-roboport",
	icon = "__concrete-roboport__/graphics/icons/concrete-roboport.png",
	icon_size = 64, icon_mipmaps = 4,
	localised_name = { "", {"entity-name.roboport"}, " MK2" },
	localised_description = { "entity-description.roboport" },
	order = "c[signal]-b[roboport]",
	place_result = "concrete-roboport",
	stack_size = 10,
	subgroup = "logistic-network"
}

data:extend({concrete_roboport_item})
