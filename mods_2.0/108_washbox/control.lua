require("shared")

local mod = {}

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
  -- valve_in.teleport(-0.5, 0)

  local valve_out = entity.surface.create_entity{
    name = mod_prefix .. "valve-out",
    force = entity.force,
    position = entity.position,
    create_build_effect_smoke = false,
  }
  -- valve_out.teleport( 0.5, 0)

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
