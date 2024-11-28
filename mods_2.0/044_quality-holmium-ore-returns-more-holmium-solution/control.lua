require("util")

local Shared = require("shared")

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read and player.cursor_stack.name == "holmium-solution-quality-multiplier" then
    player.cursor_stack.clear()
  end
end)

local mod_surface_name = "holmium-chemical-plant"

local Handler = {}

script.on_init(function()
  storage.x_offset = 0

  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
  mod_surface.create_global_electric_network()

  storage.electric_energy_interface = mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.constant_combinator = mod_surface.create_entity{
    name = "constant-combinator",
    force = "neutral",
    position = {-2.5, -0.5},
    direction = defines.direction.south,
  }

  Handler.update_constant_combinator()
end)

script.on_configuration_changed(function()
  Handler.update_constant_combinator()
end)

function Handler.update_constant_combinator()
  local cb = storage.constant_combinator.get_control_behavior() --[[@as LuaConstantCombinatorControlBehavior]]
  cb.remove_section(1)
  local section = cb.add_section() --[[@as LuaLogisticSection]]
  for _, quality in pairs(prototypes.quality) do
    if not quality.hidden then
      section.set_slot(section.filters_count + 1, {
        value = {type = "item", name = "holmium-solution-quality-based-productivity", quality = quality.name, comparator = "="},
        min = Shared.get_multiplier_for_quality(quality) - 1,
      })
    end
  end
end

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
