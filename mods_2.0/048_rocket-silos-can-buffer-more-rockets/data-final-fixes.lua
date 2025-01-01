for _, silo in pairs(data.raw["rocket-silo"]) do
  local x = tostring(silo.rocket_parts_storage_cap / silo.rocket_parts_required)
  local locale_entry = mods["platforms-do-not-request-full-stacks-of-buildings"] == nil and "fits_x_rockets" or "fits_x_rockets_comfortably"
  silo.localised_description = {
    "",
    silo.localised_description or {"entity-description." .. silo.name}, -- ugly but works "well enough" for now :D
    "\n[color=255,230,192][font=default-semibold]", {"rocket-silos-can-buffer-more-rockets." .. locale_entry, x}, "[/font][/color]"
    --string.format("\n[color=255,230,192][font=default-semibold]Fits %s rockets comfortably[/font][/color]", x)
  }
end
