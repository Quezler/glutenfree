data:extend{
  {
    type = 'custom-input',
    name =  'tcbcpodo-build',
    key_sequence = '',
    linked_game_control = 'build',
  },
  {
    type = 'custom-input',
    name =  'tcbcpodo-build-ghost',
    key_sequence = '',
    linked_game_control = 'build-ghost',
  },
  {
    type = 'simple-entity-with-force',
    name = 'tcbcpodo-mayfly',
    selection_box = {{-0.5, -0.5}, { 0.5,  0.5}},
    collision_box = {{-0.5, -0.5}, { 0.5,  0.5}},
    collision_mask = {},
    flags = {'player-creation', 'placeable-off-grid'},
    placeable_by = {item = 'coin', count = 1},
  },
}
