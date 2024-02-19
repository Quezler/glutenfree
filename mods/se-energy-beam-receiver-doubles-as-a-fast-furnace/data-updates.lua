local furnace = data.raw['furnace']['se-energy-receiver-electric-furnace'] or data.raw['assembling-machine']['se-energy-receiver-electric-furnace']
local fluid = data.raw['fluid']['se-energy-receiver-electric-furnace-fluid']

-- note that the math inside (as well as the core miner drilling mud mod) is finetuned to appear to make sense, don't take it at face value!
local function power_by_fluid(shown_mw, fluid_per_second, max_speed)
  furnace.energy_usage = 1000/6*(shown_mw/10) .. "KJ"
  furnace.crafting_speed = max_speed

  fluid_per_second = fluid_per_second / 10 -- different than for drills?
  fluid.heat_capacity = (shown_mw / 10) / (fluid_per_second * 100) .. "KJ"
  fluid.max_temperature = max_speed * 10 -- custom max temp
end

power_by_fluid(1000, 100, 10000)
