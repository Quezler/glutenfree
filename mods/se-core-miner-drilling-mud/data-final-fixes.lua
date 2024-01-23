data:extend{{
  type = 'recipe',
  name = 'se-core-miner-drill-drilling-mud',
  category = 'chemistry',
  subgroup = 'oil',

  ingredients = {
    {
      type = "fluid",
      name = "water",
      amount = 50,
    },
    {
      type = "fluid",
      name = "lubricant",
      amount = 10,
    },
    {
      type = "item",
      name = "landfill",
      amount = 1,
    },
  },

  energy_required = 2,
  
  results = {{
    type = "fluid",
    name = 'se-core-miner-drill-drilling-mud',
    temperature = 200,
    amount = 1000,
  }},

  hide_from_player_crafting = true,

  crafting_machine_tint = {
    primary = data.raw['fluid']['heavy-oil'].flow_color,
    secondary = data.raw['fluid']['light-oil'].flow_color,
  },
}}

table.insert(data.raw['technology']['se-core-miner'].effects, {type = "unlock-recipe", recipe = 'se-core-miner-drill-drilling-mud'})

local coreminer = data.raw['mining-drill']['se-core-miner-drill']
