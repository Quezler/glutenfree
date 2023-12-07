local turret = table.deepcopy(data.raw['ammo-turret']['se-meteor-point-defence-container'])
turret.type = 'electric-turret'
turret.name = 'se-interstellar-construction-requests-fulfillment--turret'

local tint = {r=244, g=209, b=6}
turret.base_picture.layers[2].tint = tint
turret.base_picture.layers[2].hr_version.tint = tint

turret.icon = nil
turret.icons = {
  {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-base.png', icon_size = 64},
  {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-mask.png', icon_size = 64, tint = tint}
}

turret.energy_source = {
  buffer_capacity = "1GJ",
  input_flow_limit = "1GW",
  type = "electric",
  usage_priority = "primary-input"
}

turret.attack_parameters = table.deepcopy(data.raw['electric-turret']['laser-turret']).attack_parameters

turret.attack_parameters.ammo_type.energy_consumption = "1GJ"
turret.energy_source.buffer_capacity = "1GJ"
turret.energy_source.input_flow_limit = "1GW"
turret.energy_source.drain = nil

log('search for this!')
log(serpent.block( turret.attack_parameters ))

-- 1.909 Script @__se-interstellar-construction-requests-fulfillment__/data.lua:30: {
--   ammo_type = {
--     action = {
--       action_delivery = {
--         beam = "laser-beam",
--         duration = 40,
--         max_length = 24,
--         source_offset = {
--           0,
--           -1.3143899999999999
--         },
--         type = "beam"
--       },
--       type = "direct"
--     },
--     category = "laser",
--     energy_consumption = "1GJ"
--   },
--   cooldown = 40,
--   damage_modifier = 2,
--   range = 24,
--   source_direction_count = 64,
--   source_offset = {
--     0,
--     -0.85587225
--   },
--   type = "beam"
-- }

turret.localised_name = nil
turret.localised_description = nil

--

local item = {
  type = 'item',
  name = 'se-interstellar-construction-requests-fulfillment--item',
  icons = {
    {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-base.png', icon_size = 64},
    {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-mask.png', icon_size = 64, tint = tint}
  },
  order = 'k-a', -- weapon delivery cannon is `j-`
  subgroup = 'surface-defense',
  stack_size = 50,
}

item.place_result = turret.name
turret.minable.result = item.name

--

data:extend({turret, item})
