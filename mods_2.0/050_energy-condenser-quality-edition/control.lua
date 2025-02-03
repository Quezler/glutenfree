mod_prefix = "quality-condenser--"

local Combinators = require("scripts.combinators")

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function reset_offering_idle(struct)
  if struct.inserter_1_offering.valid then return end
  game.print(string.format("resetting offering idle for #%d @ %d", struct.id, game.tick))
  struct.inserter_1.held_stack.clear()
  struct.inserter_1_offering = storage.surface.create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {0.5 + struct.index, -8.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_1_offering)] = {"offering-idle", struct.id}
end

local function reset_offering_done(struct)
  if struct.inserter_2_offering.valid then return end
  game.print(string.format("resetting offering done for #%d @ %d", struct.id, game.tick))
  struct.inserter_2.held_stack.clear()
  struct.inserter_2_offering = storage.surface.create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {0.5 + struct.index, -11.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_2_offering)] = {"offering-done", struct.id}
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

  -- {valid = false, destroy = function () end}
  storage.invalid = storage.surface.create_entity{
    name = "small-electric-pole",
    force = "neutral",
    position = {-2.5, -0.5},
  }
  storage.invalid.destroy()

  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}
end)

function ensure_recipe_is_set(entity)
  local recipe, quality = entity.get_recipe()
  if recipe == nil then entity.set_recipe(mod_prefix .. "a-whole-bunch-of-items") end
  return quality or prototypes.quality["normal"]
end

function Handler.on_created_entity(event)
  local entity = event.entity
  ensure_recipe_is_set(entity)

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    index = storage.index,
    entity = entity,

    container = nil,
    container_inventory = nil,
    arithmetic_1 = nil, -- each + 0 = S
    arithmetic_2 = nil, -- each + 0 = each
    decider_1 = nil, -- red T != green T | R 1
    decider_2 = nil, -- R == 0 | T = T + 1
    inserter_1 = nil, -- T = ?
    inserter_1_offering = storage.invalid,
    inserter_2 = nil, -- F > 0
    inserter_2_offering = storage.invalid,
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
  struct.container_inventory = struct.container.get_inventory(defines.inventory.chest)

  Combinators.create_for_struct(struct)
  reset_offering_idle(struct)
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

local Condense = require("scripts.condense")

local deathrattles = {
  ["offering-idle"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      reset_offering_idle(struct)
      if struct.entity.crafting_progress == 0 and struct.container_inventory.is_empty() == false then
        ensure_recipe_is_set(struct.entity)
        struct.entity.crafting_progress = 0.001
        reset_offering_done(struct)
      end
    end
  end,
  ["offering-done"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      Condense.trigger(struct)
      reset_offering_idle(struct)
    end
  end,
  ["crafter"] = function (deathrattle)
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
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle[1]](deathrattle)
  end
end)

script.on_nth_tick(60 * 60, function(event)
  for _, struct in pairs(storage.structs) do
    local signal_T = struct.inserter_1.get_signal({type = "virtual", name = "signal-T"}, defines.wire_connector_id.circuit_green)
    if signal_T > 300 then -- idle for over 5 seconds
      if struct.entity.crafting_progress == 0 and struct.container_inventory.is_empty() == false then -- is currently not crafting
        ensure_recipe_is_set(struct.entity)
        struct.entity.crafting_progress = 0.001
      end
    end
  end
end)
