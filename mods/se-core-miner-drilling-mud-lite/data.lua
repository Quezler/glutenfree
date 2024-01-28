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
  default_temperature = 15,
}}

local coreminer = data.raw['mining-drill']['se-core-miner-drill']

coreminer.input_fluid_box = {
  production_type = "input-output",
  pipe_picture = assembler3pipepictures(),
  pipe_covers = pipecoverspictures(),
  base_area = 1,
  height = 2,
  base_level = -1,
  pipe_connections =
  {
    {position = {-6,  0}},
    {position = { 6,  0}},
    {position = { 0,  6}},
  }
}

coreminer.mining_speed = 200

if mods['se-core-miner-drill-output-inventories-are-linked'] then
  table.insert(coreminer.input_fluid_box.pipe_connections, {position = { 0, -6}})
end
