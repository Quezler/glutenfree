local function update_items_per_next_quality()
  remote.call("upcycler", "set_items_per_next_quality", {
    name = "burner-upcycler",
    items = settings.global["burner-upcycling-items-per-next-quality"].value,
  })
end

script.on_init(update_items_per_next_quality)
script.on_configuration_changed(update_items_per_next_quality)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
  if event.setting_type == "runtime-global" then
    if event.setting == "burner-upcycling-items-per-next-quality" then
      update_items_per_next_quality()
    end
  end
end)
