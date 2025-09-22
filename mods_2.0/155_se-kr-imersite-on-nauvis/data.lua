data.raw["mod-data"]["se-universe-resource-word-rules"].data["kr-imersite"].forbid_homeworld = nil

data.raw["resource"]["kr-imersite"].created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {
        type = "script",
        effect_id = "k2-imersite-created",
      },
    }
  }
}
