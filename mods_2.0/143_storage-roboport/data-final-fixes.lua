require("namespace")

local entity = table.deepcopy(data.raw["roboport"]["roboport"])
entity.name = "storage-roboport"
entity.icon = mod_directory .. "/graphics/icons/storage-roboport.png"
entity.base.layers[1].filename = mod_directory .. "/graphics/entity/storage-roboport/storage-roboport-base.png"
entity.base_patch.filename = mod_directory .. "/graphics/entity/storage-roboport/storage-roboport-base-patch.png"
entity.minable.result = "storage-roboport"

local item = table.deepcopy(data.raw["item"]["roboport"])
item.name = "storage-roboport"
item.icon = mod_directory .. "/graphics/icons/storage-roboport.png"
item.place_result = entity.name

local recipe = {
  type = "recipe",
  name = "storage-roboport",
  enabled = false,
  energy_required = 10,
  ingredients =
  {
    {type = "item", name = "roboport", amount = 1},
    {type = "item", name = "sulfur", amount = 50},
  },
  results = {{type="item", name="storage-roboport", amount=1}}
}

data:extend{entity, item, recipe}

table.insert(data.raw["technology"]["construction-robotics"].effects, 2, {
  type = "unlock-recipe", recipe = "storage-roboport",
})
table.insert(data.raw["technology"]["logistic-robotics"].effects, 2, {
  type = "unlock-recipe", recipe = "storage-roboport",
})
