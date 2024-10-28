script.on_init(function()
  local items = remote.call("freeplay", "get_created_items")
  items["infinity-rocket-silo"] = 1
  items["space-platform-starter-pack"] = 1
  remote.call("freeplay", "set_created_items", items)
end)
