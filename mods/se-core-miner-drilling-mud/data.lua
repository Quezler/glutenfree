data:extend{{
  type = 'fluid',
  name = 'se-core-miner-drill-drilling-mud',
  base_color = {r=146, g=098, b=053},
  flow_color = {r=146, g=098, b=053},
  icons = {
    {icon = data.raw['fluid']['heavy-oil'].icon, icon_size = data.raw['fluid']['heavy-oil'].icon_size},
    {icon = data.raw['fluid']['light-oil'].icon, icon_size = data.raw['fluid']['light-oil'].icon_size, tint = {1, 1, 1, 0.5}},
    {icon = data.raw['item' ]['landfill' ].icon, icon_size = data.raw['item' ]['landfill' ].icon_size, scale = 0.25, shift = {0, 4}},
  },
  auto_barrel = false,
  heat_capacity = 1*2.5 .. "KJ",
  default_temperature = 0,
  max_temperature = 100,
}}

local coreminer = data.raw['mining-drill']['se-core-miner-drill']

coreminer.energy_source = {
  type = "fluid",
  fluid_box = {
    production_type = "input",
    pipe_picture = assembler2pipepictures(),
    pipe_covers = pipecoverspictures(),
    base_area = 1,
    height = 2,
    base_level = -1,
    pipe_connections =
    {
      {position = {-6,  0}},
      {position = { 6,  0}},
      {position = { 0,  6}},
    },
    filter = "se-core-miner-drill-drilling-mud",
  },
}

-- 100 fluid per second, heat is % of normal speed
coreminer.energy_usage = 1000/6*2.5 .. "KJ"
-- coreminer.mining_speed = 100
coreminer.animations.layers[2].animation_speed = 2

if mods['se-core-miner-drill-output-inventories-are-linked'] then
  table.insert(coreminer.energy_source.fluid_box.pipe_connections, {position = { 0, -6}})
end
