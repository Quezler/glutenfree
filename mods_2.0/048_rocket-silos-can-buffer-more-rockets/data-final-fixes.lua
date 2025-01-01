for _, silo in pairs(data.raw["rocket-silo"]) do
  local x = tostring(((silo.rocket_parts_storage_cap or silo.rocket_parts_required) / silo.rocket_parts_required) + 1)
  local locale_entry = mods["platforms-do-not-request-full-stacks-of-buildings"] == nil and "fits_x_rockets" or "fits_x_rockets_comfortably"
  local fits_x_rockets = {"", "[color=255,230,192][font=default-semibold]", {"rocket-silos-can-buffer-more-rockets." .. locale_entry, x}, "[/font][/color]"}
  silo.localised_description = {
    "?",
    {"", silo.localised_description or {"entity-description." .. silo.name}, "\n", fits_x_rockets},
    fits_x_rockets,
  }
end
