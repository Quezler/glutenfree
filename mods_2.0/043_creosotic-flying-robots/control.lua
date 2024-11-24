local shared = require("shared")

local sets = {}

for i, multiplier in ipairs(shared.multipliers) do
  sets[i] = {}
  local max_energy = string.format("1%sJ", multiplier)
  for j, type_and_name in ipairs({{type = "construction-robot", name = "construction-robot"}, {type = "logistic-robot", name = "logistic-robot"}}) do
    sets[i][j] = string.format("%s-%s", type_and_name.name, max_energy)
  end
end

commands.add_command("a-bucket-for-monsieur", "And a cleaning woman!", function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local surface = player.surface
  surface.create_global_electric_network()
  surface.create_entity{
    name = "electric-energy-interface",
    force = player.force,
    position = {-1, -1},
  }

  for i, set in ipairs(sets) do
    surface.create_entity{
      name = "roboport",
      force = player.force,
      position = {i * 4 - 2, -2},
    }

    surface.create_entity{
      name = set[1],
      force = player.force,
      position = {i * 4 - 2, 2},
    }

    surface.create_entity{
      name = set[2],
      force = player.force,
      position = {i * 4 - 3, 2},
    }
  end
end)
