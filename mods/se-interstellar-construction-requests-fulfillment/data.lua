local turret = table.deepcopy(data.raw['electric-turret']['se-meteor-point-defence-charger'])
turret.name = 'se-interstellar-construction-requests-fulfillment--turret'
turret.flags = {"placeable-player", "player-creation"}
turret.selectable_in_game = true

turret.base_picture.layers[2].tint = {r=244, g=209, b=6}
turret.base_picture.layers[2].hr_version.tint = turret.base_picture.layers[2].tint

turret.collision_mask = {
  "water-tile",
  "item-layer",
  "object-layer",
  "player-layer",
},

data:extend({turret})
