local ConcreteNetwork = {}

function ConcreteNetwork.add_roboport(network, roboport)
  network.roboports = network.roboports + 1
  network.roboport[roboport.unit_number] = roboport

  global.unit_number_to_network_index[roboport.unit_number] = network.index

  global.deathrattles[script.register_on_entity_destroyed(roboport)] = {roboport.surface.index, network.index}
end

function ConcreteNetwork.sub_roboport(network, roboport)
  network.roboports = network.roboports - 1
  network.roboport[roboport.unit_number] = nil

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
