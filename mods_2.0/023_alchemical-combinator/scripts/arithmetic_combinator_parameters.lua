-- combines the red and green signal
return {
  first_signal = {
    name = "signal-each",
    type = "virtual"
  },
  first_signal_networks = {
    green = true,
    red = true
  },
  operation = "+",
  output_signal = {
    name = "signal-each",
    type = "virtual"
  },
  second_constant = 0,
  second_signal_networks = {
    green = true,
    red = true
  }
}
-- /c log(serpent.block( game.player.selected.get_control_behavior().parameters ))