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
  heat_capacity = 1*2.5/2 .. "KJ", -- *5 = 10 per second, /2 = 100 per second
  default_temperature = 0,
  max_temperature = 200,
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

if mods['se-core-miner-drill-output-inventories-are-linked'] then
  table.insert(coreminer.energy_source.fluid_box.pipe_connections, {position = { 0, -6}})
end

-- 50 fluid per second, heat is % of normal speed
coreminer.energy_usage = 1000/6*2.5 .. "KJ"
coreminer.mining_speed = 200 -- twice the default
coreminer.animations.layers[2].animation_speed = 2

local up1 = table.deepcopy(data.raw['infinity-pipe']['infinity-pipe'])
local up2 = table.deepcopy(data.raw['infinity-pipe']['infinity-pipe'])
local up3 = table.deepcopy(data.raw['infinity-pipe']['infinity-pipe'])
local up4 = table.deepcopy(data.raw['infinity-pipe']['infinity-pipe'])

up1.name = 'infinity-pipe-drilling-mud-1'
up2.name = 'infinity-pipe-drilling-mud-2'
up3.name = 'infinity-pipe-drilling-mud-3'
up4.name = 'infinity-pipe-drilling-mud-4'

up1.fluid_box.pipe_connections = {up1.fluid_box.pipe_connections[1]}
up2.fluid_box.pipe_connections = {up1.fluid_box.pipe_connections[2]}
up3.fluid_box.pipe_connections = {up1.fluid_box.pipe_connections[3]}
up4.fluid_box.pipe_connections = {up1.fluid_box.pipe_connections[4]}

data:extend{up1, up2, up3, up4}
