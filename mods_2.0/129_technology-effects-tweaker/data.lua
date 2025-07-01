require("namespace")

if settings.startup[mod_prefix .. "stage"].value == "data" then
  require("prototypes.hook")
end

-- testing that hidden technologies show as grey
data.raw["technology"]["artillery"].hidden = true
