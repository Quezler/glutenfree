local created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {
        type = "script",
        effect_id = "item-request-proxy-created",
      },
    }
  }
}

local proxy = data.raw["item-request-proxy"]["item-request-proxy"]
assert(proxy.created_effect == nil, serpent.block(proxy.created_effect))
proxy.created_effect = created_effect
