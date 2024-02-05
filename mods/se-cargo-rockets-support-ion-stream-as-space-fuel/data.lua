local original = data.raw['storage-tank']['se-rocket-launch-pad-tank']

local tank = table.deepcopy(original)
tank.name = tank.name .. '-ion'

tank.collision_box = {
  {tank.collision_box[1][1], tank.collision_box[1][2] -1},
  {tank.collision_box[2][1], tank.collision_box[2][2] -1},
}
-- tank.selection_box = {
--   {tank.selection_box[1][1], tank.selection_box[1][2] -1},
--   {tank.selection_box[2][1], tank.selection_box[2][2] -1},
-- }

for _, pipe_connection in ipairs(tank.fluid_box.pipe_connections) do
  pipe_connection.position[2] = pipe_connection.position[2] - 1
end

original.fluid_box.pipe_connections = {}
original.window_bounding_box = {{0, 0}, {0, 0}}

-- the tank window is BLOODY CURSED when it comes to gasses, so we just pretend the ion stream is a liquid and hope no one complains :)
-- tank.window_bounding_box = {{-0.125, 0.6875}, {0.1875, 1.1875}},
-- tank.window_bounding_box = {
--   {tank.window_bounding_box[1][1] + 1 / 32, tank.window_bounding_box[1][2] - 0},
--   {tank.window_bounding_box[2][1] + 1 / 32, tank.window_bounding_box[2][2] - 0},
-- }
-- data.raw['fluid']['se-ion-stream'].gas_temperature = data.raw['fluid']['se-ion-stream'].default_temperature + 1
data.raw['fluid']['se-ion-stream'].gas_temperature = nil

tank.pictures.picture.sheets[1].shift = {tank.pictures.picture.sheets[1].shift[1], tank.pictures.picture.sheets[1].shift[2] -1}
tank.pictures.picture.sheets[1].hr_version.shift = tank.pictures.picture.sheets[1].shift

tank.pictures.fluid_background.shift = {tank.pictures.fluid_background.shift[1], tank.pictures.fluid_background.shift[2] -1}

tank.pictures.flow_sprite.shift = {tank.pictures.flow_sprite.shift[1], tank.pictures.flow_sprite.shift[2] -1}

tank.pictures.gas_flow.shift = {tank.pictures.gas_flow.shift[1], tank.pictures.gas_flow.shift[2] -1}
tank.pictures.gas_flow.hr_version.shift = tank.pictures.gas_flow.shift

-- lets not care about the 8 ish circuit wire properties, and instead just hide the lot
tank.draw_circuit_wires = false

data:extend{tank}

data.raw["gui-style"]["default"]["se_launchpad_progressbar_ion"] = {
  type="progressbar_style",
  parent="se_launchpad_progressbar_generic",
  color=data.raw['fluid']['se-ion-stream'].base_color
}
