local yellow_item = data.raw['item']['lane-splitter']
local yellow_entity = data.raw['lane-splitter']['lane-splitter']

local function update_icon(prototype, prefix)
  prototype.icons =
  {
    {
      icon = "__lane-balancers__/graphics/icons/" .. prefix .. "lane-splitter.png",
    },
  }
end

yellow_item.hidden = nil
yellow_entity.hidden = nil

update_icon(yellow_item, '')
update_icon(yellow_entity, '')

yellow_item.order = "d[lane-splitter]-a[" .. '' .. "lane-splitter]"
yellow_item.subgroup = "belt"

yellow_item.weight = data.raw['item']['' .. 'splitter'].weight
if yellow_item.weight then yellow_item.weight = yellow_item.weight / 2 end

yellow_item.stack_size = data.raw['item']['' .. 'splitter'].stack_size * 2

local function create_recipe(config)
  local splitter = data.raw['recipe'][config.prefix .. 'splitter']
  local balancer = table.deepcopy(splitter)

  balancer.name = config.prefix .. 'lane-splitter'

  for _, ingredient in ipairs(balancer.ingredients) do
    if ingredient.name == config.previous_prefix .. 'splitter' then
      ingredient.name = config.previous_prefix .. 'lane-splitter'
      ingredient.amount = 2
    end
  end

  balancer.results[1].name = config.prefix .. 'lane-splitter'
  balancer.results[1].amount = 2

  data:extend{balancer}

  table.insert(data.raw['technology'][config.tech].effects, {
    type = "unlock-recipe",
    recipe = balancer.name,
  })
end

create_recipe({
  prefix = '',
  tech = 'logistics',
  previous_prefix = 'this value does nothing since the yellow splitter is crafted from belts',
})

local function apply_splitter_texture_to_balancer(splitter, balancer)
  balancer.structure = table.deepcopy(splitter.structure)
  balancer.structure_patch = table.deepcopy(splitter.structure_patch)

  for _, animation_4_way in ipairs({balancer.structure, balancer.structure_patch}) do
    for _, direction in ipairs({"north", "east", "south", "west"}) do
      animation_4_way[direction].scale = (animation_4_way[direction].scale or 1) / 2
      if animation_4_way[direction].shift then -- some of the structure path are util.empty_sprite(), which has no shift
        animation_4_way[direction].shift = {animation_4_way[direction].shift[1] / 2, animation_4_way[direction].shift[2] / 2}
      end
    end
  end
end

local entity_handled_last = yellow_entity

local function handle(config)
  local item = table.deepcopy(yellow_item)
  local entity = table.deepcopy(yellow_entity)

  item.name = config.prefix .. item.name
  entity.name = config.prefix .. entity.name

  -- todo: string.gsub
  item.order = "d[lane-splitter]-" .. config.order .. "[" .. config.prefix .. "lane-splitter]"
  item.place_result = entity.name

  update_icon(item, config.prefix)
  update_icon(entity, config.prefix)

  local splitter = data.raw['splitter'][config.prefix .. 'splitter']

  entity.belt_animation_set = splitter.belt_animation_set
  entity.minable.result = item.name

  entity.speed = splitter.speed
  entity.max_health = splitter.max_health

  apply_splitter_texture_to_balancer(splitter, entity)
  create_recipe(config)

  item.weight = data.raw['item'][config.prefix .. 'splitter'].weight
  if item.weight then item.weight = item.weight / 2 end

  item.stack_size = data.raw['item'][config.prefix .. 'splitter'].stack_size * 2

  data:extend{item, entity}

  -- log(entity.name .. ' is an upgrade for ' .. entity_handled_last.name)
  entity.next_upgrade = nil -- so turbo doesn't upgrade to red
  if entity_handled_last then
    -- log(entity_handled_last.name .. ' will upgrade to ' .. entity.name)
    entity_handled_last.next_upgrade = entity.name
  end
  entity_handled_last = entity
end

-- unsupported 3rd mod support
lane_balancers_handle = handle

handle({
  prefix = 'fast-',
  tech = 'logistics-2',
  previous_prefix = '',
  order = 'b',
})

handle({
  prefix = 'express-',
  tech = 'logistics-3',
  previous_prefix = 'fast-',
  order = 'c',
})

if mods['space-age'] then
  handle({
    prefix = 'turbo-',
    tech = 'turbo-transport-belt',
    previous_prefix = 'express-',
    order = 'd',
  })

  if mods['Krastorio2-spaced-out'] then
  handle({
    prefix = 'kr-superior-',
    tech = 'kr-logistic-5',
    previous_prefix = 'turbo-',
    order = 'e',
  })
  end
end

if mods['Krastorio2'] then
  handle({
    prefix = 'kr-advanced-',
    tech = 'kr-logistic-4',
    previous_prefix = 'express-',
    order = 'd',
  })
  handle({
    prefix = 'kr-superior-',
    tech = 'kr-logistic-5',
    previous_prefix = 'kr-advanced-',
    order = 'e',
  })
end
