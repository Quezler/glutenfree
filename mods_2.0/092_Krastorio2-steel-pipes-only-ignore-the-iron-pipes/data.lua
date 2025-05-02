require("util")

names_ignored_by_steel_pipes = util.list_to_map({
  "pipe",
--"pipe-to-ground", -- since these are directional, lets allow them?
})
