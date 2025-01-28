local effects = {
  "speed",
  "productivity",
  "consumption",
  "pollution",
}

if feature_flags["quality"] then
  table.insert(effects, "quality")
end

return {
  effects = effects,
}
