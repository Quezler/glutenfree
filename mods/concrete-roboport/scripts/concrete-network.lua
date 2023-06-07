local ConcreteNetwork = {}

function ConcreteNetwork.add_roboport(network, roboport)

  local previous_network_index = global.unit_number_to_network_index[roboport.unit_number]
  if previous_network_index then
    local previous_network = global.surfaces[network.surface_index].networks[previous_network_index]
    if previous_network then
      ConcreteNetwork.sub_roboport(previous_network, roboport)
    end
  end

  network.roboports = network.roboports + 1
  network.roboport[roboport.unit_number] = roboport

  global.unit_number_to_network_index[roboport.unit_number] = network.index

  global.deathrattles[script.register_on_entity_destroyed(roboport)] = {roboport.surface.index, network.index}
end

function ConcreteNetwork.sub_roboport(network, roboport)
  if network.roboport[roboport.unit_number] == nil then error('roboport not part of this network') end

  network.roboports = network.roboports - 1
  network.roboport[roboport.unit_number] = nil

  -- game.print('now roboports ' .. network.roboports)

  -- assert(network.roboports >= 0)
  if network.roboports == 0 then
    game.print('destroy network')
    ConcreteNetwork.destroy(network)
  end
end

function ConcreteNetwork.destroy(network)
  for _, roboport_tile in pairs(network.tile) do
    roboport_tile.destroy()
  end

  global.surfaces[network.surface_index].networks[network.index] = nil
end

return ConcreteNetwork
