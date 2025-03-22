local function reset_direction(entity)
  entity.direction = defines.direction.north
end

local function on_created_entity(event)
  local entity = event.entity or event.destination
  reset_direction(entity)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter =       "name", name = "sign-post"},
    {filter = "ghost_name", name = "sign-post"},
  })
end

local mod_surface_name = "sign-post"

script.on_init(function(event)
  -- storage.index = 0
  -- storage.structs = {}
  -- storage.deathrattles = {}
end)

local function migrate_display_panel_from_version_1(entity)
  if entity.get_circuit_network(defines.wire_connector_id.circuit_red) then return end
  if entity.get_circuit_network(defines.wire_connector_id.circuit_green) then return end

  entity.order_upgrade{
    target = "sign-post",
    force = entity.force,
  }

  -- now that we have registered the upgrade we'll just trick the mod into thinking the upgrade/replace happened:

  entity.surface.create_entity{
    name = "sign-post",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }

  entity.destroy()
end

script.on_configuration_changed(function(event)
  storage.index = nil
  storage.structs = nil
  storage.deathrattles = nil

  if game.surfaces[mod_surface_name] then game.delete_surface(mod_surface_name) end

  local mod_change_data = event.mod_changes["sign-post"]
  if mod_change_data and mod_change_data.old_version and (mod_change_data.old_version == "1.0.1" or mod_change_data.old_version == "1.0.0") then
    -- no need for a "version might be 1.0.0 if 1.0.1" or vice versa since those versions do not have this mgration code at all,
    -- and well if users downgrade and cause a bloody mess that's on them, i'm not even gonna test what happens when downgrading.

    for _, surface in pairs(game.surfaces) do
      if surface.name ~= mod_surface_name then
        for _, entity in pairs(surface.find_entities_filtered({name = {"display-panel"}})) do
          migrate_display_panel_from_version_1(entity)
        end
      end
    end
  end
end)

local function get_entity_name(entity)
  return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

script.on_event(defines.events.on_player_rotated_entity, function(event)
  if get_entity_name(event.entity) then
    reset_direction(event.entity)
  end
end)

script.on_event(defines.events.on_player_flipped_entity, function(event)
  if get_entity_name(event.entity) then
    reset_direction(event.entity)
  end
end)
