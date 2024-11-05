-- filteres the red signals based on the green blacklist
return {
  conditions = {
    {
      comparator = "≠",
      compare_type = "or",
      constant = 0,
      first_signal = {
        name = "signal-each",
        type = "virtual"
      },
      first_signal_networks = {
        green = false,
        red = true
      },
      second_signal_networks = {
        green = true,
        red = true
      }
    },
    {
      comparator = "=",
      compare_type = "and",
      constant = 0,
      first_signal = {
        name = "signal-each",
        type = "virtual"
      },
      first_signal_networks = {
        green = true,
        red = false
      },
      second_signal_networks = {
        green = true,
        red = true
      }
    }
  },
  outputs = {
    {
      copy_count_from_input = true,
      networks = {
        green = true,
        red = true
      },
      signal = {
        name = "signal-each",
        type = "virtual"
      }
    }
  }
}

-- /c log(serpent.block( game.player.selected.get_control_behavior().parameters ))
