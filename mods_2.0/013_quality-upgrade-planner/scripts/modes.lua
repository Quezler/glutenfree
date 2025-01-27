local function set_mapper(upgrade_planner, i, entity_name, quality_name)
  upgrade_planner.set_mapper(i, "from", {type = "entity", name = entity_name})
  upgrade_planner.set_mapper(i, "to"  , {type = "entity", name = entity_name, quality = quality_name})
end

local function mode_entities(event, playerdata)
  local inventory = game.create_inventory(1)
  local upgrade_planner = inventory[1]
  upgrade_planner.set_stack({name = "upgrade-planner"})

  local map = {}
  for i, entity in ipairs(event.entities) do
    map[(entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype).name] = event.quality
  end

  local i = 0
  for entity_name, quality_name in pairs(map) do
    i = i + 1
    set_mapper(upgrade_planner, i, entity_name, quality_name)
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
}
