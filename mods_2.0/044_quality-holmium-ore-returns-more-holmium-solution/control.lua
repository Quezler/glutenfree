local Handler = {}

local function get_holmium_chemical_plant_entity_name(quality_name)
  return quality_name == "normal" and "holmium-chemical-plant" or quality_name .. "-holmium-chemical-plant"
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  game.print(string.format("%s got placed with %s quality.", entity.name, entity.quality.name))

  local new_entity = entity.surface.create_entity{
    name = get_holmium_chemical_plant_entity_name(entity.quality.name),
    force = entity.force,
    position = entity.position,
    direction = entity.direction,
    quality = entity.quality,
    fast_replace = true,
    create_build_smoke = false,
  }

  game.print(new_entity)
end

local filters = {}

for _, quality in pairs(prototypes.quality) do
  table.insert(filters, {filter = "name", name = get_holmium_chemical_plant_entity_name(quality.name)})
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, filters)
end
