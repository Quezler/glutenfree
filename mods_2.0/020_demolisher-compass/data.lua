local created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {
        type = "script",
        effect_id = "demolisher-compass-demolisher-created",
      },
    }
  }
}

local demolisher_names = {"small-demolisher", "medium-demolisher", "big-demolisher"}
for _, demolisher_name in ipairs(demolisher_names) do
  local prototype = data.raw["segmented-unit"][demolisher_name]
  assert(prototype, string.format("no segmented unit called %s found.", demolisher_name))

  assert(prototype.created_effect == nil, "another mod has added a created effect to a demolisher, guess we'll need to share now.")
  prototype.created_effect = created_effect
end

for i = 0, 27 do
  local delay = (i == 7 or i == 21) and "15" or "05"
  local icon = string.format("__demolisher-compass__/graphics/icons/compass/frame_%02d_delay-0.%ss.png", i, delay)
  -- log(icon)

  data:extend{{
    type = "item",
    -- name = "demolisher-compass-" .. i,
    name = string.format("demolisher-compass-%02d", i),
    localised_name = {"item-name.demolisher-compass"},

    icon = icon,
    icon_size = 160,

    stack_size = 1,
    flags = {"not-stackable", "only-in-cursor"},
    -- hidden_in_factoriopedia = true,
  }}
end
