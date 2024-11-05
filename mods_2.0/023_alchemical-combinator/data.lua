local combinator = table.deepcopy(data.raw["decider-combinator"]["decider-combinator"])
local combinator_item = table.deepcopy(data.raw["item"]["decider-combinator"])

combinator.name = "alchemical-combinator"
combinator_item.name = combinator.name

combinator.minable.result = combinator_item.name
combinator_item.place_result = combinator.name

local combinator_active = table.deepcopy(combinator)
combinator_active.name = "alchemical-combinator-active"
combinator.minable.result = nil

combinator.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator.png"
combinator_item.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator.png"
combinator_active.icon = "__alchemical-combinator__/graphics/icons/alchemical-combinator-active.png"

combinator.sprites.north.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.east .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.south.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"
combinator.sprites.west .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator.png"

-- for _, direction in ipairs({defines.direction.north, defines.direction.east, defines.direction.south, defines.direction.west}) do
for _, direction in ipairs({"north", "east", "south", "west"}) do
  local sprite = table.deepcopy(combinator_active.sprites[direction].layers[1])
  sprite.type = "sprite"
  sprite.name = "alchemical-combinator-active-" .. direction
  sprite.filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
  data:extend{sprite}
end

-- combinator_active.sprites.north = util.empty_sprite()
-- combinator_active.sprites.east  = util.empty_sprite()
-- combinator_active.sprites.south = util.empty_sprite()
-- combinator_active.sprites.west  = util.empty_sprite()
combinator_active.sprites.north.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.east .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.south.layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.west .layers[1].filename = "__alchemical-combinator__/graphics/entity/combinator/alchemical-combinator-active.png"
combinator_active.sprites.north.layers[2] = nil
combinator_active.sprites.east .layers[2] = nil
combinator_active.sprites.south.layers[2] = nil
combinator_active.sprites.west .layers[2] = nil

combinator_active.selection_priority = (combinator.selection_priority or 50) + 1

-- table.insert(combinator_active.flags, "placeable-off-grid")
-- combinator_active.selection_box = {
--   {combinator_active.selection_box[1][1], combinator_active.selection_box[1][2] - 0.01},
--   {combinator_active.selection_box[2][1], combinator_active.selection_box[2][2] - 0.01},
-- }
-- combinator_active.collision_box = {
--   {combinator_active.collision_box[1][1], combinator_active.collision_box[1][2] - 0.01},
--   {combinator_active.collision_box[2][1], combinator_active.collision_box[2][2] - 0.01},
-- }

data:extend{combinator, combinator_item, combinator_active}

local sound_charge = {
  type = "sound",
  name = "alchemical-combinator-charge",
  filename = "__alchemical-combinator__/sound/charge.ogg",
}

local sound_uncharge = {
  type = "sound",
  name = "alchemical-combinator-uncharge",
  filename = "__alchemical-combinator__/sound/uncharge.ogg",
}

data:extend{sound_charge, sound_uncharge}

local function turn_off_combinator_screen(combinator)
  for _, sprite_4_way in ipairs({"equal_symbol_sprites", "greater_symbol_sprites", "less_symbol_sprites", "not_equal_symbol_sprites", "greater_or_equal_symbol_sprites", "less_or_equal_symbol_sprites"}) do
    combinator[sprite_4_way] = nil
  end
end

turn_off_combinator_screen(combinator)
turn_off_combinator_screen(combinator_active)

local combinator_recipe = {
  type = "recipe",
  name = "alchemical-combinator",
  enabled = false,
  ingredients =
  {
    {type = "item", name = "iron-plate", amount = 1},
    {type = "item", name = "copper-plate", amount = 1},
    {type = "item", name = "sulfur", amount = 2},
    {type = "item", name = "decider-combinator", amount = 1}
  },
  results = {{type="item", name="alchemical-combinator", amount=1}}
}

data:extend{combinator_recipe}

local technology_effects = data.raw["technology"]["circuit-network"].effects
table.insert(technology_effects, {type = "unlock-recipe", recipe = combinator_recipe.name})

combinator_active.energy_source = {type = "void"}
