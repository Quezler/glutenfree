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

  global.tinted_pyramid_at = {}

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

function Ancient.zone_from_surface(surface)
  if not string.find(surface.name, "Vault ", 1, 1) then return end
  for zone_index in string.gmatch(surface.name, "Vault (%d+)") do
    return remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = tonumber(zone_index)})
  end
end

function Handler.on_post_surface_created(event)
  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  if not zone then return end

  if zone.type ~= "planet" then return end
  if zone.is_homeworld then return end

  -- determine which color the pyramid should have
  local modules = {{'productivity-module-9', 'red'}, {'speed-module-9', 'blue'}, {'effectivity-module-9', 'green'}}
  local module, color = table.unpack(modules[Ancient.gtf(zone.glyph)%#modules+1])

  -- game.print(zone.name .. color)

  -- if the module is taken, return the tint to the default :)
  local inside_surface_name = Ancient.vault_surface_name(zone)
  local inside_surface = game.get_surface(inside_surface_name)
  if inside_surface then
    local container = inside_surface.find_entity('se-cartouche-chest', {0, -14})
    if container then
      local inventory = container.get_inventory(defines.inventory.chest)
      local still_holds_original_module = inventory.get_item_count(module) > 0
      if not still_holds_original_module then
        color = 'white'
        -- game.print(serpent.block( inventory.get_contents() ))
      end
    end
  end

  -- game.print(zone.name .. color)

  -- delete the old tinted pyramid (even thought it might already be the right color)
  local positionstr = util.positiontostr(zone.vault_pyramid.position)
  local tinted_pyramid = global.tinted_pyramid_at[positionstr]
  if tinted_pyramid and tinted_pyramid.valid then
    tinted_pyramid.destroy()
  end

  -- game.print('now: ' .. color)

  -- create the tinted pyramid
  local surface = game.get_surface(event.surface_index)
  local entity = surface.create_entity({
    name = zone.vault_pyramid.name .. '-tinted-' .. color,
    position = zone.vault_pyramid.position,
  })

  global.tinted_pyramid_at[positionstr] = entity
end

function Handler.on_player_fast_transferred(event)
  if event.entity.name ~= 'se-cartouche-chest' then return end

  Handler.on_post_surface_created({surface_index = Ancient.zone_from_surface(event.entity.surface).surface_index})
end

function Handler.on_gui_closed(event)
  if not event.entity or event.entity.name ~= 'se-cartouche-chest' then return end

  Handler.on_post_surface_created({surface_index = Ancient.zone_from_surface(event.entity.surface).surface_index})
end

return Handler
