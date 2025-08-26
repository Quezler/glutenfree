local Util = require("__space-exploration-scripts__.util")
local Meteor = require("__space-exploration-scripts__.meteor")

local mod = {}

script.on_init(function()
  storage.all_ghosts = {}
  storage.new_ghosts = {}

  storage.all_proxies = {}
  storage.new_proxies = {}

  -- generally there are not a lot of diverse requests so we have an one to many relationship here
  storage.item_to_entities_map = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = {"entity-ghost", "tile-ghost"}}) do
      mod.add_new_ghost(entity)
    end
    for _, entity in ipairs(surface.find_entities_filtered{name = "item-request-proxy"}) do
      storage.new_proxies[entity.unit_number] = {entity = entity}
    end
  end

  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  assert(storage.structs == nil and storage.v1_structs == nil, "not compatible with versions below 3.0.0, remove the mod from the save first.")

  -- todo: refresh all requested items since prototype changes could have changed construction materials
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = {
    index = entity.unit_number,
    entity = entity,
    barrel = math.random(0, 3),
  }

  storage.structs[entity.unit_number] = struct
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
    {filter = "name", name = "interstellar-construction-turret"},
  })
end

function mod.fire_next_barrel(struct)
  struct.barrel = struct.barrel % 4 + 1
  struct.entity.surface.create_entity{
    name = Meteor.name_meteor_point_defence_beam,
    position = Util.vectors_add(struct.entity.position, Meteor.name_meteor_point_defence_beam_offsets[struct.barrel]),
    target = Util.vectors_add(struct.entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
  }
end

mod.add_new_ghost = function(entity)
  local unit_number = entity.unit_number

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "ghost", unit_number = unit_number}
  storage.new_ghosts[unit_number] = true
  storage.all_ghosts[unit_number] = {
    entity = entity,
    unit_number = unit_number,

    item_name_map = {},
  }
end

script.on_nth_tick(10, function(event)
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      if math.random() > 0.75 then
        mod.fire_next_barrel(struct)
      end
    end
  end
end)

-- item request proxies will not have any insertion/removal requests on creation,
-- and any other mods might react to any of their events as well,
-- so it is better to process them the next tick.
local on_script_trigger_effect_handlers = {
  ["item-request-proxy-created"] = function(entity) storage.new_request_proxies[entity.unit_number] = {entity = entity} end,
  ["entity-ghost-created"] = function(entity) mod.add_new_ghost(entity) end,
  ["tile-ghost-created"] = function(entity) mod.add_new_ghost(entity) end,
}

script.on_event(defines.events.on_script_trigger_effect, function(event)
  local handler = on_script_trigger_effect_handlers[event.effect_id]
  if handler then handler(event.source_entity) end
end)

function mod.insert_into_item_to_entities_map(item_name, ghost)
  storage.item_to_entities_map[item_name] = storage.item_to_entities_map[item_name] or {}
  storage.item_to_entities_map[item_name][ghost.entity.unit_number] = true
  ghost.item_name_map[item_name] = true
end

function mod.process_new()
  for unit_number, _ in pairs(storage.new_ghosts) do
    storage.new_ghosts[unit_number] = nil
    local ghost = storage.all_ghosts[unit_number]
    if ghost.entity.valid then
      local items_to_place_this = ghost.entity.ghost_prototype.items_to_place_this
      if items_to_place_this then
        mod.insert_into_item_to_entities_map(items_to_place_this[1].name, ghost)
      end
    end
  end
end

function mod.clean_item_to_entities_map()
  for item_name, structs in pairs(storage.item_to_entities_map) do
    if next(structs) == nil then
      storage.item_to_entities_map[item_name] = nil
    end
  end
end

script.on_event(defines.events.on_tick, function()
  mod.process_new()
  mod.clean_item_to_entities_map()
end)

script.on_nth_tick(60, function()
  log(serpent.line(storage.item_to_entities_map))
end)

local deathrattles = {
  ["ghost"] = function(deathrattle)
    local ghost = storage.all_ghosts[deathrattle.unit_number]
    storage.all_ghosts[ghost.unit_number] = nil

    for item_name, _ in pairs(ghost.item_name_map) do
      storage.item_to_entities_map[item_name][ghost.unit_number] = nil
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local handler = deathrattles[deathrattle.name]
    if handler then handler(deathrattle) end
  end
end)
