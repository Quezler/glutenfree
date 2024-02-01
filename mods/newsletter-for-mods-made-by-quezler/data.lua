local mod_prefix = 'newsletter-for-mods-made-by-quezler-'

data:extend{{
  type = 'sprite',
  name = mod_prefix .. 'crater',

  filename = '__newsletter-for-mods-made-by-quezler__/graphics/crater.png',
  height = 24,
  width = 24,

  flags = {'icon'},
}}

data:extend{
  {
    type = 'custom-input',
    name =  mod_prefix .. 'leftclick-button',
    key_sequence = '',
    linked_game_control = 'open-gui',
  },
}
