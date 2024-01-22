data:extend{{
  type = 'fluid',
  name = 'se-core-miner-drill-drilling-mud',
  default_temperature = 15,
  base_color = {r=146, g=098, b=053},
  flow_color = {r=146, g=098, b=053},
  icons = {
    {icon = data.raw['fluid']['heavy-oil'].icon, icon_size = data.raw['fluid']['heavy-oil'].icon_size},
    {icon = data.raw['item' ]['landfill' ].icon, icon_size = data.raw['item' ]['landfill' ].icon_size, scale = 0.25, shift = {0, 4}},
  }
}}

local coreminer = data.raw['mining-drill']['se-core-miner-drill']

coreminer.input_fluid_box = {
  production_type = "input-output",
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
  }
}

if mods['se-core-miner-drill-output-inventories-are-linked'] then
  table.insert(coreminer.input_fluid_box.pipe_connections, {position = { 0, -6}})
end
