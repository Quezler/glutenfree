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

-- a fake item to show whenever a player transitions surface, currently other character prototypes will also share this item/icon.
data:extend{{
  type = "item",
  name = "planet-flow-statistics-character",
  localised_name = {"entity-name.character"},

  icon = data.raw["character"]["character"].icon,
  stack_size = 1,

  flags = {"only-in-cursor", "not-stackable", "spawnable"},
  hidden_in_factoriopedia = true,
}}
