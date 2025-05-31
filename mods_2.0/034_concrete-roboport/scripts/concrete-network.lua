local ConcreteNetwork = {}

function ConcreteNetwork.add_roboport(network, roboport)
  local surfacedata = storage.surfacedata[network.surface_index]
  surfacedata.abandoned_roboports[roboport.unit_number] = nil

  network.roboports = network.roboports + 1
  network.roboport[roboport.unit_number] = roboport

  surfacedata.roboports[roboport.unit_number].last_network_index = network.index
end

function ConcreteNetwork.sub_roboport(network, roboport)
  -- log("removing roboport " .. roboport.unit_number)
  if network.roboport[roboport.unit_number] == nil then error("roboport not part of this network") end

  network.roboports = network.roboports - 1
  network.roboport[roboport.unit_number] = nil

  -- game.print("now roboports " .. network.roboports)

  -- assert(network.roboports >= 0)
  if network.roboports == 0 then
    -- log("destroy network " .. network.index)
    ConcreteNetwork.destroy(network)
  end
end

function ConcreteNetwork.destroy(network)
  log(string.format('deleting network #%d', network.index))
  network.bounding_box.destroy()

  local surfacedata = storage.surfacedata[network.surface_index]

  for unit_number, roboport in pairs(network.roboport) do
    surfacedata.abandoned_roboports[unit_number] = roboport
  end
  for unit_number, tile in pairs(network.tile) do
    surfacedata.abandoned_tiles[unit_number] = tile
  end

  storage.surfacedata[network.surface_index].networks[network.index] = nil
end

function ConcreteNetwork.increase_bounding_box_to_contain_tiles(network, tiles)
  local min_x = network.min_x
  local max_x = network.max_x
  local min_y = network.min_y
  local max_y = network.max_y

  for _, tile in ipairs(tiles) do
    if tile.x < min_x then min_x = tile.x end
    if tile.x > max_x then max_x = tile.x end
    if tile.y < min_y then min_y = tile.y end
    if tile.y > max_y then max_y = tile.y end
  end

  network.min_x = min_x
  network.max_x = max_x
  network.min_y = min_y
  network.max_y = max_y

  network.bounding_box.destroy() -- probably never called
  network.bounding_box = game.get_surface(network.surface_index).create_entity{
    name = "highlight-box",
    position = {0, 0},
    bounding_box = {{network.min_x - 0.2, network.min_y - 0.2}, {network.max_x + 1 + 0.2, network.max_y + 1 + 0.2}},
    box_type = "train-visualization",
    time_to_live = 60 * 60 * 60,
  }
end

return ConcreteNetwork
