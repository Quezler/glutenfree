local ConcreteNetwork = {}

function ConcreteNetwork.add_roboport(network, roboport)

  local previous_network_index = storage.unit_number_to_network_index[roboport.unit_number]
  if previous_network_index then
    local previous_network = storage.surfacedata[network.surface_index].networks[previous_network_index]
    if previous_network then

      -- todo: unbodge this hack
      previous_network.tiles = 0
      previous_network.tile = {}

      ConcreteNetwork.sub_roboport(previous_network, roboport)
    end
  end

  network.roboports = network.roboports + 1
  network.roboport[roboport.unit_number] = roboport

  storage.unit_number_to_network_index[roboport.unit_number] = network.index

  storage.deathrattles[script.register_on_object_destroyed(roboport)] = {surface_index = roboport.surface.index, network_index = network.index}
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
  network.valid = false
  network.bounding_box.destroy()

  for _, roboport_tile in pairs(network.tile) do
    roboport_tile.destroy()
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
