local cargo_pod = data.raw["cargo-pod"]["cargo-pod"]

cargo_pod.created_effect = {
  type = "direct",
  action_delivery = {
    type = "instant",
    source_effects = {
      {type = "script", effect_id = "cargo-pod-created"}
    }
  }
}
