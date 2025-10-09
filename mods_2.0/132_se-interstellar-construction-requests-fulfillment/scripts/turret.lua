local Util = require("__space-exploration-scripts__.util")
local Meteor = require("__space-exploration-scripts__.meteor")

return function(mod)
  local Turret = {}

  Turret.fire_next_barrel = function(turret)
    local entity = turret.entity
    turret.barrel = turret.barrel % 4 + 1
    entity.surface.create_entity{
      name = Meteor.name_meteor_point_defence_beam,
      position = Util.vectors_add(entity.position, Meteor.name_meteor_point_defence_beam_offsets[turret.barrel]),
      target = Util.vectors_add(entity.position, {x = 0, y = -Meteor.meteor_swarm_altitude})
    }
  end

  Turret.logistic_section_name = "[entity=interstellar-construction-turret] Requests"

  Turret.reset_gui = function(turret)
    if not turret.entity.valid then return end

    turret.entity.request_from_buffers = true
    turret.logistic_point.trash_not_requested = true

    local sections = turret.entity.get_logistic_sections()

    local logistic_section_found = false
    for _, section in ipairs(sections.sections) do
      if section.group == Turret.logistic_section_name then
        section.active = true
        logistic_section_found = true
      else
        sections.remove_section(section.index)
      end
    end

    if not logistic_section_found then
      sections.add_section(Turret.logistic_section_name)
    end
  end

  Turret.reset_guis = function()
    for _, turret in pairs(storage.turrets) do
      Turret.reset_gui(turret)
    end
  end

  Turret.tick_turret = function(turret)
    if not turret.entity.valid then return end

    local logistic_network = turret.entity.logistic_network
    if logistic_network then
      -- log(serpent.line(turret.inventory.get_contents()))

      -- by checking the requested contents instead of getting all the networks items and looping,
      -- or checking each of the requested items one by one, we know that the network has some available.
      for _, item in pairs(turret.inventory.get_contents()) do
        local available = logistic_network.get_item_count({name = item.name, quality = item.quality})
        local item_name_comma_quality_name = item.name .. "," .. item.quality
        local ghosts = storage.item_to_entities_map[item_name_comma_quality_name] or {}

        for unit_number, _ in pairs(ghosts) do
          local ghost = storage.all_ghosts[unit_number]
          if ghost and ghost.entity.valid then
            local wants = ghost.item_name_map[item_name_comma_quality_name]
            wants = 1 -- todo: reintroduce number?
            if available >= wants then
              local removed = logistic_network.remove_item({name = item.name, count = wants, quality = item.quality})
              assert(removed == wants)
              Turret.fire_next_barrel(turret)

              available = available - removed -- todo: grab a fresh item count in case of mod compatibility issues
            end
          end
        end

      end
    end
  end

  Turret.tick_turrets = function()
    for _, turret in pairs(storage.turrets) do
      Turret.tick_turret(turret)
    end
  end

  return Turret
end
