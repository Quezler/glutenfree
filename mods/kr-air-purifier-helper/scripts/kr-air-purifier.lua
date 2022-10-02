local construction_robot = require("construction-robot")

local kr_air_purifier = {}

function kr_air_purifier.init()
  global["kr-air-purifier"] = {}

  global["kr-air-purifier"]["all"] = {}
  global["kr-air-purifier"]["active"] = {}
  global["kr-air-purifier"]["receiving"] = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = "kr-air-purifier"}) do
      table.insert(global["kr-air-purifier"]["all"], entity)
    end
  end
end

function kr_air_purifier.on_created_entity(event)
  local purifier = event.created_entity or event.entity or event.destination
  if not (purifier and purifier.valid) then return end

  if purifier.name == "kr-air-purifier" then
    table.insert(global["kr-air-purifier"]["all"], purifier)
    local proxy = construction_robot.deliver(purifier, {["pollution-filter"] = 2})
    global["kr-air-purifier"]["receiving"][script.register_on_entity_destroyed(proxy)] = purifier
  end
end

function kr_air_purifier.on_entity_destroyed(event)
  if global["kr-air-purifier"]["receiving"][event.registration_number] then
    local purifier = global["kr-air-purifier"]["receiving"][event.registration_number]
    global["kr-air-purifier"]["receiving"][event.registration_number] = nil

    if purifier and purifier.valid then

      if purifier.get_recipe() then
      -- started using filter
        local highlighter = purifier.surface.create_entity({name = "highlight-box", box_type = "train-visualization", position = purifier.position, source = purifier, time_to_live = purifier.get_recipe().energy / purifier.crafting_speed * 60 * (1 - purifier.crafting_progress), render_player_index = 65535})
        global["kr-air-purifier"]["active"][script.register_on_entity_destroyed(highlighter)] = purifier
      else
      -- item request proxy got manually removed?
        kr_air_purifier.refill_if_empty(purifier)
      end

      local used_filters = purifier.get_inventory(defines.inventory.furnace_result)
      if not used_filters.is_empty() then
      -- has empty filters to extract

        local robot = purifier.surface.find_entity("construction-robot", purifier.position)
        if robot then
        -- construction bot still nearby

          local cargo = robot.get_inventory(defines.inventory.robot_cargo)
          if cargo.is_empty() then
          -- bot on the return trip?

            for name, count in pairs(used_filters.get_contents()) do
              cargo.insert({name = name, count = count})
            end

            used_filters.clear()
          end
        end
      end
    end
  elseif global["kr-air-purifier"]["active"][event.registration_number] then
    local purifier = global["kr-air-purifier"]["active"][event.registration_number]
    global["kr-air-purifier"]["active"][event.registration_number] = nil

    if purifier and purifier.valid then
      kr_air_purifier.refill_if_empty(purifier)
      --  if purifier.crafting_progress is not 1 in here, it lacked power
    end
  end
end

function kr_air_purifier.refill_if_empty(purifier)
  local filters = purifier.get_inventory(defines.inventory.furnace_source).get_item_count()
  if purifier.crafting_progress == 1 then
  -- assume the next tick uses one filter
    filters = filters - 1
  end

  if 1 > filters then
    if not construction_robot.pending_delivery(purifier) then
      local proxy = construction_robot.deliver(purifier, {["pollution-filter"] = 1})
      global["kr-air-purifier"]["receiving"][script.register_on_entity_destroyed(proxy)] = purifier
    end
  end
end

function kr_air_purifier.every_five_minutes()
  for i = #global["kr-air-purifier"]["all"], 1, -1 do
    local purifier = global["kr-air-purifier"]["all"][i]

    if not purifier.valid then
      table.remove(global["kr-air-purifier"]["all"], i)
    else
      -- when purifiers lacked 100% power during their recipe the event based servicing breaks,
      -- also purifiers that have more filters than expected (e.g. inserters or manual) break the loop as well.
      -- as a failsafe this is a slow loop that periodically checks if any of all the purifiers (re)qualifies for servicing.
      kr_air_purifier.refill_if_empty(purifier)
    end
  end
end

return kr_air_purifier
