require("shared")

data:extend{
  {
    type = "int-setting",
    name = mod_prefix .. "amount",
    setting_type = "startup", order = "a",
    minimum_value = 10,
    default_value = 100000, -- 100k
    maximum_value = 1000000000, -- 1 billion
  },
}
