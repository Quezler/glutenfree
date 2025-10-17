local mod = {}

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  --
end)

function new_struct(table, struct)
  assert(struct.id)
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

mod.on_created_entity_filters = {
  {filter = "name", name = "cargo-landing-pad-proxy"},
}

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,
  })

  -- if struct.cargo_landing_pad == nil then
    struct.cargo_landing_pad = entity.surface.find_entities_filtered{
      name = "cargo-landing-pad",
      position = entity.position,
      radius = 1,
    }[1]
  -- end

  if struct.cargo_landing_pad == nil then
    struct.cargo_landing_pad = entity.surface.create_entity{
      name = "cargo-landing-pad",
      force = entity.force,
      position = entity.position,
      raise_built = true,
    }
  end
  struct.cargo_landing_pad.destructible = false

  entity.proxy_target_entity = struct.cargo_landing_pad
  entity.proxy_target_inventory = defines.inventory.chest

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = struct.id}
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      if struct.cargo_landing_pad.valid then
        struct.cargo_landing_pad.surface.spill_inventory{
          position = struct.cargo_landing_pad.position,
          inventory = struct.cargo_landing_pad.get_inventory(defines.inventory.cargo_landing_pad_trash),
          force = struct.cargo_landing_pad.force,
          allow_belts = false,
          drop_full_stack = true,
        }
        struct.cargo_landing_pad.destroy()
      end
    end
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == "cargo-landing-pad-proxy" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local struct = storage.structs[entity.unit_number]

    -- some magic to prevent space exploration from destroying the gui once the real landing pad's gui closes
    if player.gui.relative["se-rocket-landing-pad-gui-proxy"] then
      local root = player.gui.relative["se-rocket-landing-pad-gui-proxy"]
      root.name = "se-rocket-landing-pad-gui"
    else
      if not player.can_reach_entity(struct.cargo_landing_pad) then
        player.play_sound({path = "utility/cannot_build"})
        player.create_local_flying_text{position = struct.entity.position, text = "Cannot reach (move 1 tile closer)"}
        player.opened = nil
        return
      end
      player.opened = struct.cargo_landing_pad
      local root = player.gui.relative["se-rocket-landing-pad-gui"]
      root.name = "se-rocket-landing-pad-gui-proxy"
      root.anchor = {gui=defines.relative_gui_type.proxy_container_gui, position=defines.relative_gui_position.left}
      player.opened = entity
    end

  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local entity = event.entity

  -- means we will have to clear up the gui ourselves tho
  if entity and entity.name == "cargo-landing-pad-proxy" then
    local root = player.gui.relative["se-rocket-landing-pad-gui"]
    if root then root.destroy() end
  end
end)

-- script.on_event(defines.events.on_player_setup_blueprint, function(event)
--   local blueprint = event.stack
--   if blueprint == nil then return end

--   local blueprint_entities = blueprint.get_blueprint_entities() or {}
--   for i, blueprint_entity in ipairs(blueprint_entities) do
--     if blueprint_entity.name == "cargo-landing-pad-proxy" then
--       local entity = event.mapping.get()[i]
--       if entity and entity.name == "cargo-landing-pad-proxy" then
--         local struct = storage.structs[entity.unit_number]
--         blueprint.set_blueprint_entity_tag(i, "name", )
--       end
--     end
--   end
-- end)
