require("util")

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "holmium-solution-quality-multiplier" then
    player.cursor_stack.clear()
  end
end)

local mod_surface_name = "holmium-chemical-plant"

script.on_init(function()
  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
  mod_surface.create_global_electric_network()
  mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }
end)

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local linked_chest_a = entity.surface.create_entity{
    name = "holmium-chemical-plant-chest",
    force = entity.force,
    position = util.moveposition({entity.position.x, entity.position.y}, entity.direction, -1),
  }
  linked_chest_a.destructible = false
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "holmium-chemical-plant"},
  })
end
