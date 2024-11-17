require("scripts.helpers")

local Handler = {}

local function create_struct()
  storage.index = storage.index + 1
  storage.structs[storage.index] = {
    id = storage.index,

    surface = nil,
    position = nil,

    thruster = nil,
    power_switch = nil,
  }
  return storage.structs[storage.index]
end

local function struct_set_thruster(struct, thruster)
  struct.thruster = thruster
  storage.deathrattles[script.register_on_object_destroyed(thruster)] = {type = "thruster", struct_id = struct.id}
end

local function get_control_behavior_position(thruster)
  return {thruster.position.x - 1.5, thruster.position.y - 1.0}
end

function Handler.on_init()
  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}

  -- storage.unit_number_to_struct_id = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = "thruster"}) do
      Handler.on_created_entity({entity = entity})
    end
  end
end

script.on_init(Handler.on_init)

local function on_created_thruster(entity)
  local power_switch_position = get_control_behavior_position(entity)
  local power_switch = surface_find_entity_or_ghost(entity.surface, power_switch_position, "thruster-control-behavior")
  if power_switch == nil then
    if entity.type == "entity-ghost" then
      power_switch = entity.surface.create_entity{
        name = "entity-ghost",
        ghost_name = "thruster-control-behavior",
        force = entity.force,
        position = power_switch_position,
      }
      power_switch.minable = false
    else
      power_switch = entity.surface.create_entity{
        name = "thruster-control-behavior",
        force = entity.force,
        position = power_switch_position,
      }
      power_switch.destructible = false
    end
    power_switch.power_switch_state = true
  end

  local struct = create_struct()
  struct.surface = entity.surface
  struct.position = entity.position
  struct_set_thruster(struct, entity)

  struct.power_switch = power_switch
end

local function on_created_thruster_control_behavior(entity)
  local thruster = surface_find_entity_or_ghost(entity.surface, entity.position, "thruster")
  if thruster == nil then return entity.destroy() end

  local cb_position = get_control_behavior_position(thruster)
  if entity.position.x ~= cb_position[1] or entity.position.y ~= cb_position[2] then return entity.destroy() end

  assert(entity.quality.name == "normal") -- why would you even place a higher quality circuit connector manually?
end


function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  local entity_name = entity.type == "entity-ghost" and entity.ghost_name or entity.name

  if entity_name == "thruster" then return on_created_thruster(entity) end
  if entity_name == "thruster-control-behavior" then return on_created_thruster_control_behavior(entity) end
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
    {filter = "name"      , name = "thruster"},
    {filter = "ghost_name", name = "thruster"},
    {filter = "name"      , name = "thruster-control-behavior"},
    {filter = "ghost_name", name = "thruster-control-behavior"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = assert(storage.structs[deathrattle.struct_id])
    assert(struct.power_switch.valid)

    if deathrattle.type == "thruster" then
      local new_thruster = surface_find_entity_or_ghost(struct.surface, struct.position, "thruster")
      if new_thruster then
        struct_set_thruster(struct, new_thruster)

        if new_thruster.type == "entity-ghost" and struct.power_switch.type ~= "entity-ghost" then
          struct.power_switch.destructible = true
          assert(struct.power_switch.die(struct.power_switch.force))
          struct.power_switch = surface_find_entity_or_ghost(struct.surface, get_control_behavior_position(new_thruster), "thruster-control-behavior")
          struct.power_switch.minable = false
        elseif new_thruster.type ~= "entity-ghost" and struct.power_switch.type == "entity-ghost" then
          struct.power_switch.destructible = true
          local _, new_power_switch = struct.power_switch.revive{}
          struct.power_switch = assert(new_power_switch)
          struct.power_switch.destructible = false
        end
      else
        struct.power_switch.destroy()
        storage.structs[struct.id] = nil
      end
    end

  end
end)
