return {
  conditions = {
    {
      comparator = ">",
      compare_type = "or",
      constant = 0,
      first_signal = {
        name = "signal-each",
        type = "virtual"
      },
      first_signal_networks = {
        green = true,
        red = true
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
