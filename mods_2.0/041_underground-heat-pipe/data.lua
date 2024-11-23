local UndergroundHeatPipe = require("prototypes.underground-heat-pipe")

UndergroundHeatPipe.make({
  prefix = "",
})

UndergroundHeatPipe.make({
  prefix = "fast-",
})

UndergroundHeatPipe.make({
  prefix = "express-",
})

if mods["space-age"] then
  UndergroundHeatPipe.make({
    prefix = "turbo-",
  })
end
