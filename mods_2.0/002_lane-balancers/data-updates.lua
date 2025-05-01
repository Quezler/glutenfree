-- prismatic belt support
for _, config in ipairs({
  {prefix = ''},
  {prefix = 'fast-'},
  {prefix = 'express-'},
  {prefix = 'turbo-'},
  {prefix = 'kr-advanced-'},
  {prefix = 'kr-superior-'},
}) do
  local balancer = data.raw["lane-splitter"][config.prefix .. "lane-splitter"]
  local splitter = data.raw[     "splitter"][config.prefix ..      "splitter"]
  if balancer and splitter then
    balancer.belt_animation_set = splitter.belt_animation_set
  end
end
