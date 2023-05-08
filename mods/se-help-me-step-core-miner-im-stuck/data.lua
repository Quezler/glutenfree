local speaker = table.deepcopy(data.raw['programmable-speaker']['programmable-speaker'])

speaker.name = 'se-core-miner-drill-speaker'
speaker.energy_source = {type = 'void'}
speaker.flags = {}
-- speaker.selectable_in_game = false
speaker.minable = nil
speaker.collision_mask = {}
-- speaker.draw_circuit_wires = false
speaker.circuit_connector_sprites = nil

data:extend({speaker})
