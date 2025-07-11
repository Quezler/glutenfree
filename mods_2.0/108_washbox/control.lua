require("shared")

local mod = {}

script.on_init(function()
  storage.deathrattles = {}
  storage.structs = {}
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  -- only this mod may place the hidden entities
  if entity.name ~= "washbox" then
    return entity.destroy()
  end

  local valve_in = entity.surface.create_entity{
    name = mod_prefix .. "valve-in",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }
  if washbox_debug then valve_in.teleport(-0.5, 0) end

  local valve_out = entity.surface.create_entity{
    name = mod_prefix .. "valve-out",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }
  if washbox_debug then valve_out.teleport( 0.5, 0) end

  local pumping_speed = entity.surface.create_entity{
    name = mod_prefix .. "pumping-speed",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }

  entity.fluidbox.add_linked_connection(1, valve_in, 1)
  entity.fluidbox.add_linked_connection(0, valve_out, 0)
  valve_in.fluidbox.add_linked_connection(0, pumping_speed, 1)
  valve_out.fluidbox.add_linked_connection(1, pumping_speed, 0)

  local pumping_speed_cb = pumping_speed.get_or_create_control_behavior() --[[@as LuaFurnaceControlBehavior]]
  pumping_speed_cb.circuit_read_recipe_finished = true

  local cb = entity.get_or_create_control_behavior() --[[@as LuaFurnaceControlBehavior]]
  cb.circuit_enable_disable = true
  cb.circuit_condition = {comparator = "≥", constant = 16, first_signal = {name = "signal-S", type = "virtual"}}

  local red_out = pumping_speed.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local red_in = entity.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(red_out.connect_to(red_in, false, defines.wire_origin.script))

  storage.structs[entity.unit_number] = {
    valve_in = valve_in,
    valve_out = valve_out,
    pumping_speed = pumping_speed,
  }
  storage.deathrattles[script.register_on_object_destroyed(entity)] = true
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "washbox"},
    {filter = "name", name = mod_prefix .. "valve-in"},
    {filter = "name", name = mod_prefix .. "valve-out"},
    {filter = "name", name = mod_prefix .. "pumping-speed"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[event.useful_id]
    if struct then storage.structs[event.useful_id] = nil
      struct.valve_in.destroy()
      struct.valve_out.destroy()
      struct.pumping_speed.destroy()
    end
  end
end)
