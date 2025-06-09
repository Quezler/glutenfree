local Planet = {}

Planet.setup_combinators = function(building)
  assert(building.is_ghost == false)

  building.proxy_container_1 = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {-0.5 + building.x_offset, -0.5}
  }
  building.proxy_container_1.proxy_target_entity = building.entity
  building.proxy_container_1.proxy_target_inventory = defines.inventory.chest
end

return Planet
