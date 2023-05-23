---------------------------------
-- Roboport changes
---------------------------------
roboport = data.raw.roboport["roboport"]
roboport.fast_replaceable_group = "roboport"
-- roboport.next_upgrade = "concrete-roboport"

---------------------------------
-- Roboport MK2
---------------------------------
roboportmk2 = table.deepcopy(roboport)
roboportmk2.name = "concrete-roboport"
roboportmk2.localised_name = { "", {"entity-name.roboport"}, " MK2" }
roboportmk2.localised_description = { "entity-description.roboport" }
roboportmk2.minable.result = "concrete-roboport"
roboportmk2.fast_replaceable_group = "roboport"
roboportmk2.corpse = "concrete-roboport-remnants"

-- double radius
-- roboportmk2.logistics_radius = roboportmk2.logistics_radius * 2
-- roboportmk2.construction_radius = roboportmk2.construction_radius * 2

-- quadruple charging capacities
-- roboportmk2.energy_source.input_flow_limit = tostring(util.parse_energy(roboportmk2.energy_source.input_flow_limit)*60*4) .. "W"
-- roboportmk2.energy_source.buffer_capacity = tostring(util.parse_energy(roboportmk2.energy_source.buffer_capacity)*4) .. "J"
-- roboportmk2.energy_usage = tostring(util.parse_energy(roboportmk2.energy_usage)*60*4) .. "W"
--roboportmk2.charging_energy = "1MW"

-- roboportmk2.robot_slots_count = 10
-- roboportmk2.material_slots_count = 10
-- roboportmk2.charging_offsets = {
--   {-1.5, 1.5}, {-0.5, 1.5}, { 0.5, 1.5}, { 1.5, 1.5},
--   {-1.5, 0.5}, {-0.5, 0.5}, { 0.5, 0.5}, { 1.5, 0.5},
--   {-1.5,-0.5}, {-0.5,-0.5}, { 0.5,-0.5}, { 1.5,-0.5},
--   {-1.5,-1.5}, {-0.5,-1.5}, { 0.5,-1.5}, { 1.5,-1.5},
-- }

-- new textures
roboportmk2.base.layers[1].filename = "__concrete-roboport__/graphics/entity/concrete-roboport/concrete-roboport-base.png"
roboportmk2.base.layers[1].hr_version.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/hr-concrete-roboport-base.png"

roboportmk2.base_patch.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/concrete-roboport-base-patch.png"
roboportmk2.base_patch.hr_version.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/hr-concrete-roboport-base-patch.png"

roboportmk2.door_animation_down.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/concrete-roboport-door-down.png"
roboportmk2.door_animation_down.hr_version.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/hr-concrete-roboport-door-down.png"

roboportmk2.door_animation_up.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/concrete-roboport-door-up.png"
roboportmk2.door_animation_up.hr_version.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/hr-concrete-roboport-door-up.png"

data:extend({ roboportmk2 })


---------------------------------
-- Roboport MK2 remnants
---------------------------------
roboportmk2_remnants = table.deepcopy(data.raw.corpse["roboport-remnants"])
roboportmk2_remnants.name = "concrete-roboport-remnants"

-- new textures
for _, anim in pairs(roboportmk2_remnants.animation) do
	anim.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/remnants/concrete-roboport-remnants.png"
	anim.hr_version.filename = "__concrete-roboport__/graphics/entity/concrete-roboport/remnants/hr-concrete-roboport-remnants.png"
end

data:extend({ roboportmk2_remnants })
