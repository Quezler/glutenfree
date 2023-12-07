local turret = table.deepcopy(data.raw['ammo-turret']['se-meteor-point-defence-container'])
turret.type = 'electric-turret'
turret.name = 'se-interstellar-construction-requests-fulfillment-turret'

local tint = {r=244, g=209, b=6}
turret.base_picture.layers[2].tint = tint
turret.base_picture.layers[2].hr_version.tint = tint

turret.icon = nil
turret.icons = {
  {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-base.png', icon_size = 64},
  {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-mask.png', icon_size = 64, tint = tint}
}

turret.energy_source = table.deepcopy(data.raw['electric-turret']['laser-turret']).energy_source
turret.attack_parameters = table.deepcopy(data.raw['electric-turret']['laser-turret']).attack_parameters

turret.localised_name = nil
turret.localised_description = nil

data:extend({turret})
