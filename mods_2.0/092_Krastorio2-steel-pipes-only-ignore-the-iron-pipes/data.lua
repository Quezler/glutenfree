require("util")

-- global table shared between all mods for compat
names_ignored_by_steel_pipes = util.list_to_map({
  "pipe",
})

assert(data.raw["pipe"]["kr-steel-pipe"], 'No mod enabled that adds ["pipe"]["kr-steel-pipe"].')
data.raw["pipe-to-ground"]["kr-steel-pipe-to-ground"].fluid_box.pipe_connections[1].connection_category = "kr-steel-pipe"

for _, pipe_connection in ipairs(data.raw["pipe-to-ground"]["kr-steel-pipe-to-ground"].fluid_box.pipe_connections) do
  if (pipe_connection.connection_type or "normal") == "normal" then
    assert(pipe_connection.connection_category == "kr-steel-pipe")
    pipe_connection.connection_category = {"default", "kr-steel-pipe"}
  end
end
