util = require("util")

local Handler = {}

function Handler.on_init()
  global.surfaces = {}

  -- nauvis & adding it halfway through run
  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})

    for chunk in surface.get_chunks() do
      local position = {x = chunk.x, y = chunk.y}
      if Handler.is_chunk_charted(surface, position) then
        Handler.on_chunk_charted({position = position, surface_index = surface.index})
      end
    end
  end
end

local force_charting_ignored = util.list_to_map({'neutral', 'enemy'})

function Handler.is_chunk_charted(surface, position) -- by any player force, only called when the mod is added
  for _, force in pairs(game.forces) do
    if not force_charting_ignored[force.name] then
      if force.is_chunk_charted(surface, position) then
        return true
      end
    end
  end

  return false
end

local pollutable = util.list_to_map({'planet', 'moon'})

function Handler.on_surface_created(event)
  local struct = {
    chunks = {},
    pollution = true,
  }
  
  -- local surface = game.get_surface(event.surface_index)
  -- print(surface.name)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  if zone and pollutable[zone.type] then
    print(zone.name)
    struct.pollution = false
  end

  -- if pollutable[zone.type] then
  -- else
  --   print('not pollutable!')
  --   print(zone.type)
  -- end

  -- print(serpent.block( zone ))

  global.surfaces[event.surface_index] = struct
end

function Handler.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end

function Handler.on_chunk_charted(event)

  local chunk_key = util.positiontostr(event.position)
  if global.surfaces[event.surface_index].chunks[chunk_key] == nil then
    local surface = game.get_surface(event.surface_index)

    -- print(serpent.block(surface.name), chunk_key)

    local entity_to_create = {
      name = "mr-blue-sky",
      position = {event.position.x * 32 + 16, event.position.y * 32 + 16} -- the center of each chunk
    }
  
    -- todo: do we even need this check if we track it with global.surfaces anyways?
    -- if surface.can_place_entity(entity_to_create) then
    if not surface.find_entity(entity_to_create.name, entity_to_create.position) then
      surface.create_entity(entity_to_create)
    else
      game.print('you should not see this message, contact Quezler.')
    end

    global.surfaces[event.surface_index].chunks[chunk_key] = true
  end



  -- game.forces['player'].chart(event.surface, event.area)
end

function Handler.on_chunk_deleted(event)
  for _, position in ipairs(event.positions) do
    local chunk_key = util.positiontostr(position)
    global.surfaces[event.surface_index].chunks[chunk_key] = nil
  end
end

return Handler
