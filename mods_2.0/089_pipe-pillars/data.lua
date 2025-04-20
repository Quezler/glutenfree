local pipe = data.raw["pipe"]["pipe"]

-- error(serpent.block(pipe.fluid_box.pipe_connections))
pipe.fluid_box.pipe_connections = {
  {
    direction = 0,
    position = {
      -0.2,
      -0.2
    }
  },
  {
    direction = 4,
    position = {
      -0.2,
      -0.2
    }
  },
  {
    direction = 8,
    position = {
      -0.2,
      -0.2
    }
  },
  {
    direction = 12,
    position = {
      -0.2,
      -0.2
    }
  }
}

pipe.selectable_in_game = false
