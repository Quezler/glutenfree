mod_prefix = "quality-condenser--"

local Combinators = require("scripts.combinators")

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function reset_offering_1(struct)
  game.print(string.format("resetting offering 1 for #%d @ %d", struct.id, game.tick))
  struct.inserter_1.held_stack.clear()
  struct.inserter_1_offering = storage.surface.create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {0.5 + struct.index, -9.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_1_offering)] = {"offering-1", struct.id}
end

local function reset_offering_2(struct)
  game.print(string.format("resetting offering 2 for #%d @ %d", struct.id, game.tick))
  struct.inserter_1.held_stack.clear()
  struct.inserter_1_offering = storage.surface.create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {0.5 + struct.index, -11.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_1_offering)] = {"offering-2", struct.id}
end

local Handler = {}

script.on_init(function()
  storage.surface = game.planets["quality-condenser"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}
end)

function Handler.on_created_entity(event)
  local entity = event.entity

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    index = storage.index,
    entity = entity,

    container = nil,
    arithmetic_1 = nil, -- each + 0 = S
    arithmetic_2 = nil, -- each + 0 = each
    decider_1 = nil, -- red T != green T | R 1
    decider_2 = nil, -- R == 0 | T = T + 1
    inserter_1 = nil, -- T = ?
    inserter_1_offering = nil,
    inserter_2 = nil, -- F > 0
    inserter_2_offering = nil,
  })
  storage.index = storage.index + 1

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {"crafter", struct.id}

  struct.container = entity.surface.create_entity{
    name = mod_prefix .. "container",
    force = entity.force,
    position = entity.position,
    quality = entity.quality,
  }
  struct.container.destructible = false

  Combinators.create_for_struct(struct)
  reset_offering_1(struct)
  reset_offering_2(struct)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  -- defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = mod_prefix .. "crafter"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle[1] == "offering-1" then
      local struct = storage.structs[deathrattle[2]]
      if struct then reset_offering_1(struct) end
    elseif deathrattle[1] == "offering-2" then
      local struct = storage.structs[deathrattle[2]]
      if struct then reset_offering_2(struct) end
    elseif deathrattle[1] == "crafter" then
      local struct = storage.structs[deathrattle[2]]
      struct.arithmetic_1.destroy()
      struct.arithmetic_2.destroy()
      struct.decider_1.destroy()
      struct.decider_2.destroy()
      struct.inserter_1.destroy()
      struct.inserter_1_offering.destroy()
      struct.inserter_2.destroy()
      struct.inserter_2_offering.destroy()
      storage.structs[struct.id] = nil
    else
      error(serpent.block(deathrattle))
    end
  end
end)
