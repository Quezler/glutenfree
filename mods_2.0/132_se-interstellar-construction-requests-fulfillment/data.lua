local meld = require("meld")

local tint = {r=244, g=209, b=6}

local container = table.deepcopy(data.raw["logistic-container"]["requester-chest"])
container.name = "interstellar-construction-turret"

container.selection_box = {{-1.50, -1.50}, {1.50, 1.50}}
container.collision_box = {{-1.35, -1.35}, {1.35, 1.35}}
container.drawing_box_vertical_extension = 2.85

container.icon = nil
container.icons = table.deepcopy(data.raw["item"]["se-meteor-point-defence"].icons)
container.icons[2].tint = tint

container.animation = table.deepcopy(data.raw["ammo-turret"]["se-meteor-point-defence-container"].graphics_set.base_visualisation.animation.north)
container.animation.layers[2].tint = tint

container.inventory_size = 40
container.quality_affects_inventory_size = false
container.inventory_type = "normal"
container.use_exact_mode = true

container.circuit_connector = nil
container.circuit_wire_max_distance = nil
container.corpse = "medium-remnants"
container.dying_explosion = "medium-explosion"
container.fast_replaceable_group = nil
container.max_health = 2000
container.resistances = {
  {type = "impact", percent = 100},
  {type = "fire"  , percent = 100},
}

table.insert(container.flags, "hide-alt-info")
table.insert(container.flags, "no-automated-item-removal")
table.insert(container.flags, "no-automated-item-insertion")

local character = {
  type = "character",
  name = "interstellar-construction-character",

  selection_priority = 51,
  selection_box = {{-0.3, -0.3}, {0.3, 0.3}},
  collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
  collision_mask = {layers = {}},

  animations = {{
    idle_with_gun = util.empty_animation(),
    running_with_gun = meld(util.empty_animation(), {direction_count = 18}),
    mining_with_tool = util.empty_animation(),
  }},
  mining_speed = 1,
  running_speed = 1,
  distance_per_frame = 1,
  maximum_corner_sliding_distance = 1,
  inventory_size = 10,
  build_distance = 1,
  drop_item_distance = 1,
  reach_distance = 1,
  reach_resource_distance = 1,
  item_pickup_distance = 1,
  loot_pickup_distance = 1,
  ticks_to_keep_gun = 1,
  ticks_to_keep_aiming_direction = 1,
  ticks_to_stay_in_combat = 1,
  damage_hit_tint = {1, 1, 1, 1},
  running_sound_animation_positions = {},
  mining_with_tool_particles_animation_positions = {},
  moving_sound_animation_positions = {},

  guns_inventory_size = 1,
  has_belt_immunity = true,

  prevent_jetpack = true,
  hidden = true,
}

character.icons = table.deepcopy(data.raw["item"]["se-meteor-point-defence"]).icons
character.icons[2].tint = tint
table.insert(character.icons, {icon = data.raw["character"]["character"].icon, scale = 0.25, shift = {8, 8}})

-- log(serpent.block(container))

--

local item = {
  type = "item",
  name = container.name,
  order = "k-a", -- weapon delivery cannon is `j-`
  subgroup = "surface-defense",
  stack_size = 50,
  flags = {"draw-logistic-overlay"},
}

item.icons = table.deepcopy(data.raw["item"]["se-meteor-point-defence"]).icons
item.icons[2].tint = tint

item.place_result = container.name
container.minable.result = item.name

--

local recipe = {
  type = "recipe",
  name = item.name,
  enabled = false,
  energy_required = 30,
  ingredients = {
    {type = "item", name = "sulfur", amount = 50},
    {type = "item", name = "se-meteor-point-defence", amount = 1},
  },
  results = {{type = "item", name = item.name, amount = 1}},
  requester_paste_multiplier = 1,
}

--

local technology = {
  type = "technology",
  name = recipe.name,
  effects = {
    { type = "unlock-recipe", recipe = recipe.name }
  },
  order = "e-h",
  prerequisites = {
    "se-meteor-point-defence",
    "construction-robotics",
    "space-science-pack",
  },
  unit = {
    count = 250,
    ingredients = {
      {"automation-science-pack", 1},
      {"logistic-science-pack"  , 1},
      {"chemical-science-pack"  , 1},
      {"se-rocket-science-pack" , 1},
      {"space-science-pack"     , 1},
    },
    time = 30
  }
}

technology.icons = table.deepcopy(data.raw["technology"]["se-meteor-point-defence"]).icons
technology.icons[2].tint = tint

--

data:extend{container, character, item, recipe, technology}

local function add_created_trigger(prototype)
  prototype.created_effect = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "script",
          effect_id = prototype.name .. "-created",
        },
      }
    }
  }
end

add_created_trigger(data.raw["item-request-proxy"]["item-request-proxy"])
add_created_trigger(data.raw["entity-ghost"]["entity-ghost"])
add_created_trigger(data.raw["tile-ghost"]["tile-ghost"])


