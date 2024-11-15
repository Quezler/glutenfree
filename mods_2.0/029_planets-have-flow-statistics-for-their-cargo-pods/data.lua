if mods["platforms-do-not-request-full-stacks-of-buildings"] then return end

local cargo_pod = data.raw["cargo-pod"]["cargo-pod"]

local created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {
        type = "script",
        effect_id = "cargo-pod-created",
      },
    }
  }
}

assert(cargo_pod.created_effect == nil, "another mod has added a created effect to the cargo pod, guess we'll need to share now.")
cargo_pod.created_effect = created_effect
