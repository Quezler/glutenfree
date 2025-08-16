local mod_prefix = "glutenfree-se-spaceship-juicebox-"
local se_util = require("__space-exploration__.scripts.util")

--

local Juicebox = {}

-- manual alignment
Juicebox.offset = {
  x = 32 - 31.0234375,
  y = 13 - 13.015625,
}

function Juicebox.on_init()
  storage.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = "se-spaceship-console"})) do
      Juicebox.on_created_entity({tick = game.tick, entity = entity})
    end
  end
end

-- when the spaceship console is initially placed
function Juicebox.on_created_entity(event)
  local entity = event.created_entity or event.entity -- or event.destination
  -- game.print(event.tick .. " creating a new juicebox")

  local juicebox = entity.surface.create_entity({
    name = mod_prefix .. "storage",
    position = {entity.position.x - Juicebox.offset.x, entity.position.y - Juicebox.offset.y},
    force = entity.force,
  })
  juicebox.set_inventory_size_override(defines.inventory.chest, 10)

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {console = entity, juicebox = juicebox}
end

function Juicebox.on_object_destroyed(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    -- game.print(event.tick .. " deathrattled")
    if deathrattle.juicebox.valid then

      local inventory = deathrattle.juicebox.get_inventory(defines.inventory.chest)
      deathrattle.juicebox.surface.spill_inventory{
        position = deathrattle.juicebox.position,
        inventory = inventory,
        enable_looted = false,
        force = deathrattle.juicebox.force,
        allow_belts = false,
      }

      deathrattle.juicebox.destroy()
    end

  end
end

-- the spaceship just launched, we'll check if the roboport networks on board have enough space for bots to land.
function Juicebox.roboport_housing(surface, juicebox)
  local network = surface.find_closest_logistic_network_by_position(juicebox.position, juicebox.force)
  if not network then return end

  local juicebox_inventory = juicebox.get_inventory(defines.inventory.chest)

  local items = {} -- assume the robot items share the same name with the entity, and that they are all normal quality.
  for _, robot in ipairs(network.robots) do
    items[robot.name] = (items[robot.name] or 0) + 1
  end

  local roboport_inventories = {}
  for _, cell in ipairs(network.cells) do
    table.insert(roboport_inventories, cell.owner.get_inventory(defines.inventory.roboport_robot))
  end

  for _, robot in ipairs(network.robots) do

    -- try to fit any cargo into an onboard requester/storage/juicebox
    local cargo_stack = robot.get_inventory(defines.inventory.robot_cargo)[1]
    if cargo_stack.valid_for_read then
      if network.insert(cargo_stack) == cargo_stack.count then
        cargo_stack.clear()
      else
        goto next_robot -- cargo has nowhere to go, we'll leave this bot alone
      end
    end

    -- try to fit the robot into any of the onboard roboports
    local item = {type = "item", name = robot.name, count = 1, quality = robot.quality}
    for _, roboport_inventory in ipairs(roboport_inventories) do
      if roboport_inventory.insert(item) > 0 then
        robot.destroy()
        goto next_robot
      end
    end

    -- otherwise put the robot in the juicebox
    if juicebox_inventory.insert(item) > 0 then
      robot.destroy()
      goto next_robot
    end

    ::next_robot::
  end
end

function Juicebox.on_entity_cloned(event)
  -- game.print(event.tick .. " " .. event.destination.name)

  -- the juicebox has been cloned/moved, empty the old
  if event.source.name == mod_prefix .. "storage" then
    event.source.destroy()
    return
  end

  if event.source.name == "se-spaceship-console" then

    local position = {event.destination.position.x - Juicebox.offset.x, event.destination.position.y - Juicebox.offset.y}
    local juicebox = nil
      or event.destination.surface.find_entity(mod_prefix .. "storage", position)
      or event.destination.surface.find_entity(mod_prefix .. "active-provider", position)

    local juicebox_mode = mod_prefix .. "storage"
    local logistic_network = event.destination.surface.find_logistic_network_by_position(position, event.destination.force)
    if logistic_network and Juicebox.logistic_network_has_available_storages_other_than_just_juiceboxes(logistic_network) then
      juicebox_mode = mod_prefix .. "active-provider"
    end
    -- game.print("juicebox_mode = " .. juicebox_mode)

    if juicebox.name ~= juicebox_mode then
      local old_juicebox = juicebox -- fast replace doesn't work, presumably because there are no collision layers

      juicebox = juicebox.surface.create_entity({
        name = juicebox_mode,
        force = event.source.force, -- use the force of the console, in case of capture changes and such
        position = position,
        -- fast_replace = true
      })
      juicebox.set_inventory_size_override(defines.inventory.chest, 10)

      se_util.swap_inventories(old_juicebox.get_inventory(defines.inventory.chest), juicebox.get_inventory(defines.inventory.chest))
      old_juicebox.destroy()
    end

    local surface_name = event.destination.surface.name
    if string.sub(surface_name, 1, #"spaceship-") == "spaceship-" then
      Juicebox.roboport_housing(event.destination.surface, juicebox)
    end

    storage.deathrattles[script.register_on_object_destroyed(event.destination)] = {console = event.destination, juicebox = juicebox}
  end
end

function Juicebox.logistic_network_has_available_storages_other_than_just_juiceboxes(logistic_network)
  for _, storage in ipairs(logistic_network.storages) do
    if storage.name ~= mod_prefix .. "storage" and storage.storage_filter == nil then
      return true
    end
  end

  return false
end

return Juicebox
