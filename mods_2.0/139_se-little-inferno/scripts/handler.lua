util = require("util")
local Zone = require("__space-exploration-scripts__.zone")

local Handler = {}

function Handler.on_init()
  storage.next_tick_events = {}
  storage.surfaces = {}

  -- nauvis & adding it halfway through run
  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index, name = defines.events.on_surface_created})
  end
end

function Handler.on_configuration_changed()
  for _, surface in pairs(game.surfaces) do
    if not storage.surfaces[surface.index] then
      Handler.on_surface_created({surface_index = surface.index, name = defines.events.on_surface_created})
    end
  end
end

function Handler.on_load()
  if #storage.next_tick_events > 0 then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.on_tick(event)
  for _, e in ipairs(storage.next_tick_events) do
    if e.name == defines.events.on_surface_created then Handler.on_post_surface_created(e) end
  end

  storage.next_tick_events = {}
  script.on_event(defines.events.on_tick, nil)
end

local force_charting_ignored = util.list_to_map({"neutral", "enemy"})

function Handler.is_chunk_charted(surface, position) -- by any player force, only called for new (or freshly enabled) surfaces
  for _, force in pairs(game.forces) do
    if not force_charting_ignored[force.name] then
      if force.is_chunk_charted(surface, position) then
        return true
      end
    end
  end

  return false
end

function Handler.on_surface_created(event)
  storage.surfaces[event.surface_index] = {
    enabled = false,
    chunks = {},
  }

  table.insert(storage.next_tick_events, event)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

-- Zone.export_zone does not expose the threat, nor is there a remote call at the time of writing for it :(
function Handler.get_threat(zone)
  if zone.is_homeworld and zone.surface_index then
    local surface = game.get_surface(zone.surface_index) --[[@as LuaSurface]]
    local mapgen = surface.map_gen_settings
    if mapgen.autoplace_controls["enemy-base"] and mapgen.autoplace_controls["enemy-base"].size then
      return math.max(0, math.min(1, mapgen.autoplace_controls["enemy-base"].size / 3)) -- 0-1
    end
  end
  if zone.controls and zone.controls["enemy-base"] and zone.controls["enemy-base"].size then
    local threat = math.max(0, math.min(1, zone.controls["enemy-base"].size / 3)) -- 0-1
    -- if Zone.is_biter_meteors_hazard(zone) then
    --   return math.max(threat, 0.01)
    -- end
    return threat
  end
end

-- zone.hostiles_extinct does gets set after confirming extinction, but do all natively peaceful zones have it set to true by default?
function Handler.hostiles_extinct(zone)
  return Handler.get_threat(zone) == 0 -- or 0.01 if we cared enough about biter meteors
end

local pollutable = util.list_to_map({"planet", "moon"})

function Handler.on_post_surface_created(event)
  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  if zone and pollutable[zone.type] then

    -- game.print(zone.name .. " " .. Handler.get_threat(zone) .. " " .. tostring(Handler.hostiles_extinct(zone)))
    if Handler.hostiles_extinct(zone) then
      Handler.set_enabled_for_surface_index({surface_index = event.surface_index, enabled = true})
    end

  end
end

function Handler.on_surface_deleted(event)
  storage.surfaces[event.surface_index] = nil
end

function Handler.on_chunk_charted(event)
  if not storage.surfaces[event.surface_index].enabled then return end

  local chunk_key = util.positiontostr(event.position)
  if storage.surfaces[event.surface_index].chunks[chunk_key] == nil then
    local surface = game.get_surface(event.surface_index) --[[@as LuaSurface]]

    -- print(serpent.block(surface.name), chunk_key)

    local entity_to_create = {
      name = "se-little-inferno",
      position = {event.position.x * 32 + 16, event.position.y * 32 + 16} -- the center of each chunk
    }

    local entity = surface.find_entity(entity_to_create.name, entity_to_create.position)
    if not entity then
      entity = surface.create_entity(entity_to_create)
    else
      error("chunk already has a pollution clearing entity somehow.")
    end

    storage.surfaces[event.surface_index].chunks[chunk_key] = entity
  end

end

function Handler.on_chunk_deleted(event)
  for _, position in ipairs(event.positions) do
    local chunk_key = util.positiontostr(position)
    storage.surfaces[event.surface_index].chunks[chunk_key] = nil
  end
end

--

function Handler.on_entity_cloned(event)
  event.destination.destroy() -- gotta pay the cheese tax
end

function Handler.script_raised_destroy(event)
  local position = {x = math.floor(event.entity.position.x / 32), y = math.floor(event.entity.position.y / 32)}
  local chunk_key = util.positiontostr(position)

  -- there's more than one pollution clearing entity in this chunk? only replace the main one :)
  if event.entity == storage.surfaces[event.entity.surface.index].chunks[chunk_key] then 
    storage.surfaces[event.entity.surface.index].chunks[chunk_key] = event.entity.surface.create_entity{
      name = "se-little-inferno",
      position = {position.x * 32 + 16, position.y * 32 + 16} -- the center of each chunk
    }
  else
    game.print('more than one "se-little-inferno" in a chunk?')
  end
end

--

function Handler.get_enabled_for_surface_index(data)
  return storage.surfaces[data.surface_index].enabled
end

function Handler.set_enabled_for_surface_index(data)
  if storage.surfaces[data.surface_index].enabled == data.enabled then return end

  if data.enabled == true then
    storage.surfaces[data.surface_index].enabled = true
    local surface = game.surfaces[data.surface_index]
    for chunk in surface.get_chunks() do
      local position = {x = chunk.x, y = chunk.y}
      if Handler.is_chunk_charted(surface, position) then
        Handler.on_chunk_charted({position = position, surface_index = surface.index})
      end
    end
  elseif data.enabled == false then
    for _, entity in pairs(storage.surfaces[data.surface_index].chunks) do
      entity.destroy() -- entity.valid not needed for .destroy()
    end
    storage.surfaces[data.surface_index].chunks = {}
    storage.surfaces[data.surface_index].enabled = false
  else
    error("enabled must be a boolean.")
  end
end

function Handler.on_gui_click(event)
  if not event.element.valid then return end
  if event.element.tags.action ~= "confirm-extinction" then return end

  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.element.tags.zone_index})
  -- game.print(serpent.block(event.element.tags))

  table.insert(storage.next_tick_events, {surface_index = zone.surface_index, name = defines.events.on_surface_created})
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

function Handler.on_trigger_created_entity(event)
  if not event.entity and event.entity.valid then return end
  local entity_name = event.entity.name

  if entity_name == "se-plague-cloud" then
    local surface_index = event.entity.surface.index
    local zone = Zone.from_surface_index(surface_index)

    if zone and Zone.is_solid(zone) then
      Handler.set_enabled_for_surface_index({surface_index = surface_index, enabled = true})
    end
  end
end

return Handler
