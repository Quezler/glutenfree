local Shared = require("shared")

for _, resource in ipairs(Shared.resources) do
  resource.product = resource.product or resource.name

  -- prevent zones from having space age ores as their primary resource or as ore
  data.raw["mod-data"]["se-universe-resource-word-rules"].data[resource.name] = {
    forbid_space = true,
    forbid_orbit = true,
    forbid_belt = true,
    forbid_field = true,
    forbid_planet = true,
    forbid_homeworld = true,
  }

  se_core_fragment_resources = se_core_fragment_resources or {}
  se_core_fragment_resources[resource.product] = se_core_fragment_resources[resource.product] or {
    multiplier = 0, -- do not create a pulverizer recipe for this resource/fragment
    omni_multiplier = 0, -- do not output this resource when crushing omni fragments
  }
end

-- todo: remove when space exploration 0.7.45 drops
if mods["quality"] and settings.startup["se-quality-mod-support"].value == false then
  local data_util = require("__space-exploration__/data_util")
  data_util.tech_remove_effects("quality-module", {{type = "unlock-quality", quality = "uncommon"}})
  data_util.tech_remove_effects("quality-module", {{type = "unlock-quality", quality = "rare"}})
  data_util.tech_remove_effects("epic-quality", {{type = "unlock-quality", quality = "epic"}})
  data_util.tech_remove_effects("legendary-quality", {{type = "unlock-quality", quality = "legendary"}})
end

-- https://github.com/wube/Factorio/commit/7226d95f9a3a8656e37d739d7d5bb100dab7b432
-- Fixed base game space science getting throughput limited due to limited hatches. (https://forums.factorio.com/118064)
local procession_graphic_catalogue_types = require("__base__/prototypes/planet/procession-graphic-catalogue-types")
data.raw["cargo-landing-pad"]["cargo-landing-pad"].cargo_station_parameters.hatch_definitions =
{
  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),

  planet_upper_hatch({0.5, -3.5},  2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_1),
  planet_upper_hatch({2, -3.5},    2.25, 3, -0.5, procession_graphic_catalogue_types.planet_hatch_emission_in_2),
  planet_upper_hatch({1.25, -2.5}, 1.25, 3, -1  , procession_graphic_catalogue_types.planet_hatch_emission_in_3),
}
data.raw["cargo-landing-pad"]["cargo-landing-pad"].cargo_station_parameters.giga_hatch_definitions =
{
  planet_upper_giga_hatch({0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29})
}
