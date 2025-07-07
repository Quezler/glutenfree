local planet_map_gen = require("__space-age__/prototypes/planet/planet-map-gen")

planet_map_gen.world_of_goo = function()
  return
  {
    property_expression_names =
    {
      elevation = "fulgora_elevation",
      temperature = "temperature_basic",
      moisture = "moisture_basic",
      aux = "aux_basic",
      cliffiness = "fulgora_cliffiness",
      cliff_elevation = "cliff_elevation_from_elevation",
    },
    cliff_settings =
    {
      name = "cliff-fulgora",
      control = "fulgora_cliff",
      cliff_elevation_0 = 80,
      -- Ideally the first cliff would be at elevation 0 on the coastline, but that doesn't work,
      -- so instead the coastline is moved to elevation 80.
      -- Also there needs to be a large cliff drop at the coast to avoid the janky cliff smoothing
      -- but it also fails if a corner goes below zero, so we need an extra buffer of 40.
      -- So the first cliff is at 80, and terrain near the cliff shouln't go close to 0 (usually above 40).
      cliff_elevation_interval = 40,
      cliff_smoothing = 0, -- This is critical for correct cliff placement on the coast.
      richness = 0.95
    },
    autoplace_controls =
    {
      -- ["scrap"] = {},
      ["fulgora_islands"] = {},
      ["fulgora_cliff"] = {},
    },
    autoplace_settings =
    {
      ["tile"] =
      {
        settings =
        {
          -- ["oil-ocean-shallow"] = {},
          -- ["oil-ocean-deep"] = {},
          ["fulgoran-rock"] = {},
          ["fulgoran-dust"] = {},
          ["fulgoran-sand"] = {},
          ["fulgoran-dunes"] = {},
          -- ["fulgoran-walls"] = {},
          -- ["fulgoran-paving"] = {},
          -- ["fulgoran-conduit"] = {},
          -- ["fulgoran-machinery"] = {},
          [mod_prefix .. "crude-oil-shallow"] = {},
          [mod_prefix .. "crude-oil-deep"] = {},
        }
      },
      ["decorative"] =
      {
        settings =
        {
          -- ["fulgoran-ruin-tiny"] = {},
          -- ["fulgoran-gravewort"] = {},
          -- ["urchin-cactus"] = {},
          ["medium-fulgora-rock"] = {},
          ["small-fulgora-rock"] = {},
          ["tiny-fulgora-rock"] = {},
        }
      },
      ["entity"] =
      {
        settings =
        {
          -- ["scrap"] = {},
          ["fulgoran-ruin-vault"] = {},
          -- ["fulgoran-ruin-attractor"] = {},
          -- ["fulgoran-ruin-colossal"] = {},
          -- ["fulgoran-ruin-huge"] = {},
          -- ["fulgoran-ruin-big"] = {},
          -- ["fulgoran-ruin-stonehenge"] = {},
          -- ["fulgoran-ruin-medium"] = {},
          -- ["fulgoran-ruin-small"] = {},
          -- ["fulgurite"] = {},
          -- ["big-fulgora-rock"] = {}
          ["goo-ball"] = {}
        }
      }
    }
  }
end

return planet_map_gen
