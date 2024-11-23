local UndergroundHeatPipe = require("prototypes.underground-heat-pipe")

UndergroundHeatPipe.make({
  prefix = "",
  order = "a",
})

UndergroundHeatPipe.make({
  prefix = "fast-",
  order = "b",
})

UndergroundHeatPipe.make({
  prefix = "express-",
  order = "c",
})

if mods["space-age"] then
  UndergroundHeatPipe.make({
    prefix = "turbo-",
    order = "d",
  })
end
