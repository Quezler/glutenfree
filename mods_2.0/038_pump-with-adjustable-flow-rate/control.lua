local Handler = {}

local mod_surface_name = "pump-with-adjustable-flow-rate"
local circuit_red = defines.wire_connector_id.circuit_red
local circuit_green = defines.wire_connector_id.circuit_green

script.on_init(function()
  storage.x_offset = 0
  storage.structs = {}
  storage.deathrattles = {}

  local mod_surface = game.planets[mod_surface_name].create_surface()
  mod_surface.generate_with_lab_tiles = true
  mod_surface.create_global_electric_network()
  mod_surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }
end)

local function reset_offering(struct)
  game.print('resetting offering @ ' .. game.tick)
  struct.inserter_offering = game.surfaces[mod_surface_name].create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {-0.5 + struct.x_offset, -2.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_offering)] = {type = "offering", struct_id = struct.id}
end

local function get_next_circuit_condition(struct)
  if struct.speed <= 0 then
    return {
      comparator = ">",
      constant = 0,
      first_signal = {
        name = "signal-F",
        type = "virtual"
      }
    }
  elseif struct.speed >= 1200 then
    return {
      comparator = "<",
      constant = 1200,
      first_signal = {
        name = "signal-F",
        type = "virtual"
      }
    }
  else
    return {
      comparator = "!=",
      constant = struct.speed,
      first_signal = {
        name = "signal-F",
        type = "virtual"
      }
    }
  end
end

local function tick_struct(struct)
  struct.speed = struct.inserter.get_signal({type = "virtual", name = "signal-F"}, circuit_red, circuit_green)
  struct.inserter_cb.circuit_condition = get_next_circuit_condition(struct)

  struct.pump.fluidbox[2] = {
    name = "pump-with-adjustable-flow-rate",
    amount = 100,
    temperature = struct.speed,
  }
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local filter = entity.fluidbox.get_filter(2)
  assert(filter)
  assert(filter.name == "pump-with-adjustable-flow-rate")

  local struct = {id = entity.unit_number}
  storage.structs[struct.id] = struct
  storage.x_offset = storage.x_offset + 1
  struct.x_offset = storage.x_offset
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {type = "pump", struct_id = struct.id}

  local mod_surface = game.surfaces[mod_surface_name]

  struct.pump = entity
  struct.speed = 0
  struct.inserter = mod_surface.create_entity{
    name = "inserter",
    force = "neutral",
    position = {-0.5 + struct.x_offset, -1.5},
  }

  local inserter_red   = struct.inserter.get_wire_connector(defines.wire_connector_id.circuit_red  , true)
  local inserter_green = struct.inserter.get_wire_connector(defines.wire_connector_id.circuit_green, true)
  assert(entity.get_wire_connector(defines.wire_connector_id.circuit_red  , true).connect_to(inserter_red  , false))
  assert(entity.get_wire_connector(defines.wire_connector_id.circuit_green, true).connect_to(inserter_green, false))

  struct.inserter_cb = struct.inserter.get_control_behavior() --[[@as LuaInserterControlBehavior]]
  struct.inserter_cb.circuit_enable_disable = true

  tick_struct(struct)
  reset_offering(struct)
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
    {filter = "name", name = "pump-with-adjustable-flow-rate"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct == nil then return end

    if deathrattle.type == "offering" then
      struct.inserter.held_stack.clear()
      tick_struct(struct)
      reset_offering(struct)
    elseif deathrattle.type == "pump" then
      struct.inserter.destroy()
      struct.inserter_offering.destroy()
      storage.structs[struct.id] = nil
    else
      error(serpent.block(deathrattle))
    end

  end
end)

-- every hour minutes we'll refuel all the pumps, pumps running on full the entire time without circuit changes will be around 13 of 100
script.on_nth_tick(60 * 60 * 10 * 6, function(event)
  for _, struct in pairs(storage.structs) do
    tick_struct(struct)
  end
end)
