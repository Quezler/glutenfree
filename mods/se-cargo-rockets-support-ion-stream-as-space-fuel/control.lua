local Spaceship = require('__space-exploration-scripts__.spaceship')

local function register_fuel()
  remote.call("se-cargo-rocket-custom-fuel-lib", "add_fuel", {
    name = "se-ion-stream",
    -- fuel_value = game.fluid_prototypes["se-ion-stream"].fuel_value, -- the default
    fuel_value = Spaceship.ion_stream_energy, -- 4'000'000
    require_space = true, -- makes it not work on planets & moons
  })

  -- remote.call("se-cargo-rocket-custom-fuel-lib", "add_fuel", {
  --   name = "steam", -- lunar landings go brrr 
  --   fuel_value = 10000000, -- (steam has no fuel value by default)
  -- })

  -- remote.call("se-cargo-rocket-custom-fuel-lib", "add_fuel", {
  --   name = "biomethanol", -- krastorio wood gas, over two times weaker than rocket fuel
  --   fuel_value = game.fluid_prototypes["se-liquid-rocket-fuel"].fuel_value * 1.1 -- so lets make it match, with 10% extra for effort
  -- })
end

script.on_init(register_fuel)
script.on_configuration_changed(register_fuel)
