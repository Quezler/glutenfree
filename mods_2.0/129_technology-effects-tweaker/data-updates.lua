require("namespace")

if settings.startup[mod_prefix .. "stage"].value == "data-updates" then
  require("prototypes.hook")
end
