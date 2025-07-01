require("namespace")

if settings.startup[mod_prefix .. "stage"].value == "data" then
  require("prototypes.hook")
end
