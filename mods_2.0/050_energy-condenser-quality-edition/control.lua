local mod_prefix = "quality-disruptor--"

local Handler = {}

script.on_init(function()
  storage.surface = game.planets["quality-disruptor"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  -- storage.index = 0
  -- storage.structs = {}
  -- storage.deathrattles = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity

  local container = entity.surface.create_entity{
    name = mod_prefix .. "container",
    force = entity.force,
    position = entity.position,
    quality = entity.quality,
  }
  container.destructible = false
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  -- defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = mod_prefix .. "furnace"},
  })
end
