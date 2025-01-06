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

if mods["space-age"] or mods["factorioplus"] then
  UndergroundHeatPipe.make({
    prefix = "turbo-",
    order = "d",
  })
end

if mods["factorioplus"] then
  UndergroundHeatPipe.make({
    prefix = "supersonic-",
    order = "e",
  })
end
