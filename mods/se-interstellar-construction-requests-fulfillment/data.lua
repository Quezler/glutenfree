local turret = table.deepcopy(data.raw['ammo-turret']['se-meteor-point-defence-container'])
turret.name = 'se-interstellar-construction-requests-fulfillment-container'

local tint = {r=244, g=209, b=6}
turret.base_picture.layers[2].tint = tint
turret.base_picture.layers[2].hr_version.tint = tint

turret.icon = nil
turret.icons = {
  {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-base.png', icon_size = 64},
  {icon = '__space-exploration-graphics__/graphics/icons/meteor-point-defence-mask.png', icon_size = 64, tint = tint}
}

data:extend({turret})
