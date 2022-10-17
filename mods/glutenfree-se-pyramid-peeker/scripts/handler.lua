-- fake some of the globals so ancient can load without errors
mod_prefix = 'se-'
core_util = require('__core__/lualib/util.lua')
Event = {}
function Event.addListener() end
Util = require('__space-exploration__.scripts.util')
local Ancient = require('__space-exploration__.scripts.ancient')
-- Util = nil
Event = nil
core_util = nil
mod_prefix = nil

--

local Handler = {}

function Handler.on_init()
  global.next_tick_events = {}

  for _, surface in pairs(game.surfaces) do
    Handler.on_post_surface_created({surface_index = surface.index})
  end
end

function Handler.on_load()
  if #global.next_tick_events > 0 then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.on_surface_created(event)
  event.tick = event.tick + 1
  table.insert(global.next_tick_events, event)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

function Handler.on_tick(event)
  for _, e in ipairs(global.next_tick_events) do
    Handler.on_post_surface_created(e)
  end
  global.next_tick_events = {}
  script.on_event(defines.events.on_tick, nil)
end

local offsets = {
  ['se-pyramid-a'] = {x = -2, y = 0.01}, -- tilted west
  ['se-pyramid-b'] = {x =  0, y = 0.01}, -- tilted none
  ['se-pyramid-c'] = {x =  2, y = 0.01}, -- tilted east
}

function Handler.on_post_surface_created(event)
  -- game.print('the surface now exists :)')
  -- game.print(event.surface_index)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  if not zone then return end

  if zone.type ~= "planet" then return end
  if zone.is_homeworld then return end

  -- game.print(serpent.block( zone.vault_pyramid ))
  -- game.print(serpent.block( zone.vault_pyramid_position ))

  local surface = game.get_surface(event.surface_index)
  local offset = offsets[zone.vault_pyramid.name]
  local cargo = surface.create_entity({
    name = 'glutenfree-se-pyramid-peeker-container',
    force = 'neutral',
    position = {zone.vault_pyramid_position.x + offset.x, zone.vault_pyramid_position.y + offset.y},
  })

  local items = {"productivity-module-", "speed-module-", "effectivity-module-"}
  local module = items[Ancient.gtf(zone.glyph)%#items+1]..'9'

  -- module = 'se-cartouche-chest'

  -- cargo.insert({name='se-cartouche-chest-with-one-' .. module, count=1})
  cargo.insert({name=module, count=1})
end



return Handler
