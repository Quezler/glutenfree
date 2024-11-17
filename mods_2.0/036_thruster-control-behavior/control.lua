-- require("util")

local Handler = {}

function Handler.on_init()
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = "thruster"}) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

script.on_init(Handler.on_init)

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local power_switch = entity.surface.create_entity{
    name = "thruster-control-behavior",
    force = entity.force,
    position = {entity.position.x - 1.5, entity.position.y - 1.0},
  }

  power_switch.destructible = false

  -- rendering.draw_sprite{
  --   sprite = "thruster-control-behavior",
  --   surface = entity.surface,
  --   target = {entity = power_switch, offset = util.by_pixel(-10, -3)},
  --   render_layer = "higher-object-under",
  -- }
end

for _, event in ipairs({
  -- defines.events.on_built_entity,
  -- defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  -- defines.events.script_raised_built,
  -- defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "thruster"},
  })
end
