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
  -- heat_capacity = 1*2.5/2 .. "KJ", -- *5 = 10 per second, /2 = 100 per second
  -- default_temperature = 0,
  -- max_temperature = 200,
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
-- coreminer.energy_usage = 1000/6*2.5 .. "KJ"
-- coreminer.mining_speed = 200 -- twice the default
-- coreminer.animations.layers[2].animation_speed = 2

local up0 = table.deepcopy(data.raw['infinity-pipe']['infinity-pipe'])
local ptg = table.deepcopy(data.raw['pipe-to-ground']['pipe-to-ground'])

up0.fluid_box.base_level = -1
up0.minable = {mining_time = 0.1}
up0.placeable_by = {item = 'pipe-to-ground', count = 1}
table.insert(up0.flags, 'not-blueprintable')
up0.gui_mode = "none"

up0.pictures.ending_up = ptg.pictures.up
up0.pictures.ending_down = ptg.pictures.down
up0.pictures.ending_left = ptg.pictures.left
up0.pictures.ending_right = ptg.pictures.right

local up1 = table.deepcopy(up0) -- place @ bottom
local up2 = table.deepcopy(up0) -- place @ right
local up3 = table.deepcopy(up0) -- place @ top
local up4 = table.deepcopy(up0) -- place @ left

up1.name = 'infinity-pipe-drilling-mud-1'
up2.name = 'infinity-pipe-drilling-mud-2'
up3.name = 'infinity-pipe-drilling-mud-3'
up4.name = 'infinity-pipe-drilling-mud-4'

up1.fluid_box.pipe_connections = {up1.fluid_box.pipe_connections[1]}
up2.fluid_box.pipe_connections = {up2.fluid_box.pipe_connections[2]}
up3.fluid_box.pipe_connections = {up3.fluid_box.pipe_connections[3]}
up4.fluid_box.pipe_connections = {up4.fluid_box.pipe_connections[4]}

up1.pictures.straight_vertical_single = up1.pictures.ending_up
up2.pictures.straight_vertical_single = up1.pictures.ending_right
up3.pictures.straight_vertical_single = up1.pictures.ending_down
up4.pictures.straight_vertical_single = up1.pictures.ending_left

data:extend{up1, up2, up3, up4}

local function power_by_fluid(per_second, default_speed, max_speed)
  coreminer.energy_usage = 1000/6*2.5 .. "KJ"
  coreminer.mining_speed = max_speed
  coreminer.animations.layers[2].animation_speed = max_speed / default_speed

  data.raw['fluid']['se-core-miner-drill-drilling-mud'].heat_capacity = 1*2.5/2 .. "KJ"
  data.raw['fluid']['se-core-miner-drill-drilling-mud'].default_temperature = 0
  data.raw['fluid']['se-core-miner-drill-drilling-mud'].max_temperature = max_speed
end

power_by_fluid(100, 100, 200)
