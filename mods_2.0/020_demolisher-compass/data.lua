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
