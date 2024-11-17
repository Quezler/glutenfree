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

    -- associated_entities = {},
  }
  return storage.structs[storage.index]
end

-- local function associate_entity_with_struct(entity, struct)
--   assert(entity.unit_number)
--   assert(struct.id)

--   storage.unit_number_to_struct_id[entity.unit_number] = struct.id
--   struct.associated_entities[entity.unit_number] = entity
-- end

local function struct_set_thruster(struct, thruster)
  struct.thruster = thruster
  storage.deathrattles[script.register_on_object_destroyed(thruster)] = {type = "thruster", struct_id = struct.id}
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

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local power_switch = surface_find_entity_or_ghost(entity.surface, entity.position, "thruster-control-behavior")
  if power_switch == nil then
    power_switch = entity.surface.create_entity{
      name = "thruster-control-behavior",
      force = entity.force,
      position = {entity.position.x - 1.5, entity.position.y - 1.0},
    }
    power_switch.destructible = false
  end

  local struct = create_struct()
  struct.surface = entity.surface
  struct.position = entity.position
  struct_set_thruster(struct, entity)

  struct.power_switch = power_switch
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
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = assert(storage.structs[deathrattle.struct_id])

    if deathrattle.type == "thruster" then
      local new_thruster = surface_find_entity_or_ghost(struct.surface, struct.position, "thruster")
      if new_thruster then
        struct_set_thruster(struct, new_thruster)
      else
        struct.power_switch.destroy()
        storage.structs[struct.id] = nil
      end
    end
  end
end)
