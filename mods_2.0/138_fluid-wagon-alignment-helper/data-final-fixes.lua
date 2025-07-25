require("namespace")

local mod_data = {}

for _, prototype in pairs(data.raw["fluid-wagon"]) do
  mod_data[prototype.name] = prototype.tank_count
end

data:extend{{
  type = "mod-data",
  name = mod_prefix .. "tank-count",
  data = mod_data
}}
