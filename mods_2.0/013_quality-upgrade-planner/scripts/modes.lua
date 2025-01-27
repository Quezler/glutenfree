local module_names = {}
for _, item_prototype in pairs(prototypes.item) do
  if item_prototype.type == "module" then
    table.insert(module_names, item_prototype.name)
  end
end

local function mode_entities(event, playerdata)
  local inventory = game.create_inventory(1)
  inventory[1].set_stack({name = "upgrade-planner"})
  local upgrade_planner = inventory[1]

  local map = {}
  for i, entity in ipairs(event.entities) do
    map[(entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype).name] = event.quality
  end

  local i = 0
  for entity_name, quality_name in pairs(map) do
    i = i + 1
    upgrade_planner.set_mapper(i, "from", {type = "entity", name = entity_name})
    upgrade_planner.set_mapper(i, "to"  , {type = "entity", name = entity_name, quality = quality_name})
  end

  event.surface.upgrade_area{
    area = event.area,
    force = playerdata.player.force,
    player = playerdata.player,
    skip_fog_of_war = true,
    item = upgrade_planner,
  }

  inventory.destroy()
end

local filter_support_for_entity_type = { -- drills, asteroid collectors & storage chests have filters too, but it makes little sense to touch them.
  ["inserter"] = true,
  ["loader"] = true,

  ["splitter"] = true,
  ["lane-splitter"] = true,
}

local type_is_a_splitter = {
  ["splitter"] = true,
  ["lane-splitter"] = true,
}

local function mode_filters(event, playerdata)

  for _, entity in ipairs(event.entities) do
    if filter_support_for_entity_type[entity.type] then
      for i = 1, entity.filter_slot_count do
        local filter = entity.get_filter(i)
        if filter then
          filter.quality = event.quality
          entity.set_filter(i, filter)
        end
      end

      if type_is_a_splitter[entity.type] then
        local filter = entity.splitter_filter
        if filter then
          filter.quality = event.quality
          entity.splitter_filter = filter
        end
      end
    end
  end
end

local function mode_modules(event, playerdata)
  local inventory = game.create_inventory(1)
  inventory[1].set_stack({name = "upgrade-planner"})
  local upgrade_planner = inventory[1]

  for i, module_name in pairs(module_names) do
    upgrade_planner.set_mapper(i, "from", {type = "item", name = module_name})
    upgrade_planner.set_mapper(i, "to"  , {type = "item", name = module_name, quality = event.quality})
  end

  event.surface.upgrade_area{
    area = event.area,
    force = playerdata.player.force,
    player = playerdata.player,
    skip_fog_of_war = true,
    item = upgrade_planner,
  }

  inventory.destroy()
end

return {
  entities = mode_entities,
  filters = mode_filters,
  modules = mode_modules,
}
