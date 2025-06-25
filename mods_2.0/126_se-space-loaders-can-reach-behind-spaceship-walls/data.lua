local loader = table.deepcopy(data.raw["loader-1x1"]["kr-se-loader"])

loader.name = loader.name .. "-spaceship"
loader.container_distance = loader.container_distance + 1
loader.placeable_by = {item = "kr-se-loader", count = 1}

data:extend{loader}
