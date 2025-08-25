local Util = require("__space-exploration-scripts__.util")
local Meteor = require("__space-exploration-scripts__.meteor")

local mod = {}

script.on_init(function()
  storage.old_request_proxies = {}
  storage.old_entity_ghosts = {}
  storage.old_tile_ghosts = {}

  storage.new_request_proxies = {}
  storage.new_entity_ghosts = {}
  storage.new_tile_ghosts = {}

  -- generally there are not a lot of diverse requests so we have an one to many relationship here
  storage.item_to_entities_map = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = "item-request-proxy"}) do
      storage.new_request_proxies[entity.unit_number] = {entity = entity}
    end
    for _, entity in ipairs(surface.find_entities_filtered{name = "entity-ghost"}) do
      storage.new_entity_ghosts[entity.unit_number] = {entity = entity}
    end
    for _, entity in ipairs(surface.find_entities_filtered{name = "tile-ghost"}) do
      storage.new_tile_ghosts[entity.unit_number] = {entity = entity}
    end
  end

  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  assert(storage.structs == nil and storage.v1_structs == nil, "not compatible with versions below 3.0.0, remove the mod from the save first.")
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
  ["entity-ghost-created"] = function(entity) storage.new_entity_ghosts[entity.unit_number] = {entity = entity} end,
  ["tile-ghost-created"] = function(entity) storage.new_tile_ghosts[entity.unit_number] = {entity = entity} end,
}

script.on_event(defines.events.on_script_trigger_effect, function(event)
  local handler = on_script_trigger_effect_handlers[event.effect_id]
  if handler then handler(event.source_entity) end
end)

function mod.process_new()
  for unit_number, item_proxy in pairs(storage.new_request_proxies) do
    storage.old_request_proxies[unit_number] = item_proxy
  end

  for unit_number, entity_ghost in pairs(storage.new_entity_ghosts) do
    storage.old_entity_ghosts[unit_number] = entity_ghost
    local items_to_place_this = entity_ghost.entity.ghost_prototype.items_to_place_this
    if items_to_place_this then
      local item_to_place_this = items_to_place_this[1]
      entity_ghost.wants_item = item_to_place_this.name
      storage.item_to_entities_map[item_to_place_this.name] = storage.item_to_entities_map[item_to_place_this.name] or {}
      storage.item_to_entities_map[item_to_place_this.name][unit_number] = entity_ghost.entity
    end
  end

  for unit_number, tile_ghost in pairs(storage.new_tile_ghosts) do
    storage.old_tile_ghosts[unit_number] = tile_ghost
  end

  storage.new_request_proxies = {}
  storage.new_entity_ghosts = {}
  storage.new_tile_ghosts = {}
end

function mod.process_deathrattles()
  for unit_number, entity_ghost in pairs(storage.old_entity_ghosts) do
    if not entity_ghost.entity.valid then
      storage.old_entity_ghosts[unit_number] = nil
      if entity_ghost.wants_item then
        storage.item_to_entities_map[entity_ghost.wants_item][unit_number] = nil
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
  mod.process_deathrattles()
  mod.clean_item_to_entities_map()
end)

script.on_nth_tick(60, function()
  log(serpent.line(storage.item_to_entities_map))
end)
