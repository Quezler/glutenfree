local function on_created_entity(event)
  local entity = event.entity or event.destination

  entity.direction = defines.direction.north
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = "sign-post"},
  })
end

local mod_surface_name = "sign-post"

local function validate_mod_surface()
  local mod_surface = game.surfaces[mod_surface_name]
  if mod_surface == nil then
    mod_surface = game.create_surface(mod_surface_name)
    mod_surface.generate_with_lab_tiles = true
  end

  for _, force in pairs(game.forces) do
    force.set_surface_hidden(mod_surface_name, true)
  end
end

script.on_event(defines.events.on_force_created, function(event)
  event.force.set_surface_hidden(mod_surface_name, true)
end)

script.on_init(function(event)
  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}
  validate_mod_surface()
end)


local function migrate_display_panel_from_version_1(entity)
  if entity.get_circuit_network(defines.wire_connector_id.circuit_red) then return end
  if entity.get_circuit_network(defines.wire_connector_id.circuit_green) then return end

  -- game.print(game.tick .. " ordered")
  entity.order_upgrade{
    target = "sign-post",
    force = entity.force,
  }

  entity.surface.create_entity{
    name = "sign-post",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }

  -- game.print(game.tick .. " destroyed")
  entity.destroy()

  -- entity.surface.spill_item_stack{
  --   position = entity.position,
  --   stack = {name = "sign-post", count = 1},
  --   force = entity.force,
  --   allow_belts = false,
  -- }
end

-- local function force_upgrades()
--   for _, struct in pairs(storage.structs) do
--     local entity = struct.entity
--     entity.surface.create_entity{
--       name = "sign-post",
--       force = entity.force,
--       position = entity.position,
--       create_build_effect_smoke = false,
--       preserve_ghosts_and_corpses = true,
--     }

--     entity.destroy()
--   end

--   script.on_nth_tick(game.tick, nil)
-- end

script.on_configuration_changed(function(event)
  storage.index = storage.index or 0
  storage.structs = storage.structs or {}
  storage.deathrattles = storage.deathrattles or {}
  validate_mod_surface()

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

    -- script.on_nth_tick(game.tick + 1, force_upgrades)
  end
end)

local function anticipate_upgrade(entity, upgrade_target_name)
  if entity.surface.name == mod_surface_name then return end -- someone inspecting the hidden surface
  -- if entity.unit_number == 5 then error() end
  -- game.print(game.tick .. " anticipated " .. entity.unit_number)
  storage.index = storage.index + 1
  local backup = entity.clone{
    position = {0.5 + storage.index, -0.5},
    surface = game.surfaces[mod_surface_name],
    force = entity.force,
    create_build_effect_smoke = false,
  }

  if storage.structs[entity.unit_number] then
    -- game.print(game.tick .. " old backup removed")
    storage.structs[entity.unit_number].backup.destroy()
  end

  assert(backup)
  assert(backup.valid)

  -- game.print(game.tick .. " cloned")

  storage.structs[entity.unit_number] = {
    entity = entity,
    surface = entity.surface,
    position = entity.position,

    backup = backup,
    upgrade_target_name = upgrade_target_name,
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = entity.unit_number}
end

script.on_event(defines.events.on_marked_for_upgrade, function(event)
  -- game.print(game.tick .. " marked for upgrade " .. event.entity.unit_number .. event.entity.surface.name)
  anticipate_upgrade(event.entity, event.target.name)
end, {
  {filter = "name", name = "sign-post"},
  {filter = "name", name = "display-panel"},
})

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct_id = assert(deathrattle.struct_id)
    local struct = assert(storage.structs[struct_id])

    -- game.print(game.tick .. " deathrattle")
    -- game.print(serpent.line(struct))
    local target = struct.surface.find_entity(struct.upgrade_target_name, struct.position)
    if target then
      target.copy_settings(struct.backup)
    end

    struct.backup.destroy()
    storage.structs[struct_id] = nil
  end
end)

local opposite = {
  ["sign-post"] = "display-panel",
  ["display-panel"] = "sign-post",
}

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = player.selected

  if entity and opposite[entity.name] then
    anticipate_upgrade(entity, opposite[entity.name])
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity

  if entity and opposite[entity.name] then
    anticipate_upgrade(entity, opposite[entity.name])
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  local entity = event.destination
  if opposite[entity.name] then
    anticipate_upgrade(entity, opposite[entity.name])
  end
end)
