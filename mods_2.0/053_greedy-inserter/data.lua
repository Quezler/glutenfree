local technology = data.raw["technology"]["fast-inserter"]
technology.icon = "__greedy-inserter__/graphics/technology/fast-inserter.png"
table.insert(technology.effects, {type = "unlock-recipe", recipe = "greedy-inserter"})

local entity = table.deepcopy(data.raw["inserter"]["fast-inserter"])
entity.name = "greedy-inserter"
