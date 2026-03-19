local function add_created_trigger(prototype)
  prototype.created_effect = {
    type = "direct",
    action_delivery = {
      type = "instant",
      source_effects = {
        {
          type = "script",
          effect_id = prototype.name .. "-created",
        },
      }
    }
  }
end

add_created_trigger(data.raw["item-request-proxy"]["item-request-proxy"])
