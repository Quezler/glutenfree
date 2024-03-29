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

  energy_required = 50,
  
  results = {{
    type = "fluid",
    name = 'se-core-miner-drill-drilling-mud',
    amount = 200,
  }},

  hide_from_player_crafting = true,

  crafting_machine_tint = {
    primary = data.raw['fluid']['heavy-oil'].flow_color,
    secondary = data.raw['fluid']['light-oil'].flow_color,
  },
}}

table.insert(data.raw['technology']['se-core-miner'].effects, {type = "unlock-recipe", recipe = 'se-core-miner-drill-drilling-mud'})
