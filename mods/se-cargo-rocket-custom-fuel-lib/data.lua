local original = data.raw['storage-tank']['se-rocket-launch-pad-tank']

local tank = table.deepcopy(original)
tank.name = tank.name .. '-mixed'

tank.collision_box = {
  {tank.collision_box[1][1], tank.collision_box[1][2] -1},
  {tank.collision_box[2][1], tank.collision_box[2][2] -1},
}
tank.selection_box = {
  {tank.selection_box[1][1], tank.selection_box[1][2] -1},
  {tank.selection_box[2][1], tank.selection_box[2][2] -1},
}

for _, pipe_connection in ipairs(tank.fluid_box.pipe_connections) do
  pipe_connection.position[2] = pipe_connection.position[2] - 1
end

original.fluid_box.pipe_connections = {}
original.window_bounding_box = {{0, 0}, {0, 0}}

-- greetings traveler, here is your quest! get this right both fluids ans gasses:

-- tank.window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
-- tank.window_bounding_box = {
--   {tank.window_bounding_box[1][1] + 1 / 32, tank.window_bounding_box[1][2] - 0},
--   {tank.window_bounding_box[2][1] + 1 / 32, tank.window_bounding_box[2][2] - 0},
-- }

tank.pictures.picture.sheets[1].shift = {tank.pictures.picture.sheets[1].shift[1], tank.pictures.picture.sheets[1].shift[2] -1}
tank.pictures.picture.sheets[1].hr_version.shift = tank.pictures.picture.sheets[1].shift

tank.pictures.fluid_background.shift = {tank.pictures.fluid_background.shift[1], tank.pictures.fluid_background.shift[2] -1}

tank.pictures.flow_sprite.shift = {tank.pictures.flow_sprite.shift[1], tank.pictures.flow_sprite.shift[2] -1}

tank.pictures.gas_flow.shift = {tank.pictures.gas_flow.shift[1], tank.pictures.gas_flow.shift[2] -1}
tank.pictures.gas_flow.hr_version.shift = tank.pictures.gas_flow.shift

tank.draw_circuit_wires = false

data:extend{tank}
