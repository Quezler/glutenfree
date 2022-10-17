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

  global.pyramids_to_visit = {}

  for _, surface in pairs(game.surfaces) do
    Handler.on_post_surface_created({surface_index = surface.index})
  end
end

function Handler.on_load()
  if #global.next_tick_events > 0 or #global.pyramids_to_visit > 0 then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.on_surface_created(event)
  table.insert(global.next_tick_events, event)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

local remote_view_to_restore = nil

function Handler.find_a_player_that_can_enter_pyramids()
  for _, player in ipairs(game.connected_players) do
    remote_view_to_restore = nil

    if not player.character and remote.call("space-exploration", "remote_view_is_active", {player=player}) then
      remote_view_to_restore = {
        player = player,
        zone_name = player.surface.name,
        position = player.position,
      }
      remote.call("space-exploration", "remote_view_stop", {player=player})
    end

    if player.character then
      remote.call("jetpack", "stop_jetpack_immediate", {character = player.character}) -- todo: restore flight?
      player.driving = false -- todo: restore driving?

      -- cannot check if the player is also stuck in a pending tick task
      return player
    end
  end
end

function Handler.on_tick(event)
  for _, e in ipairs(global.next_tick_events) do
    Handler.on_post_surface_created(e)
  end
  global.next_tick_events = {}

  if #global.pyramids_to_visit > 0 then
    if #game.connected_players > 0 then
      local player = Handler.find_a_player_that_can_enter_pyramids()
      if player then
        -- game.print('yoink')
        local old_surface = player.surface
        local old_position = player.position

        for _, pyramid in ipairs(global.pyramids_to_visit) do
          player.teleport(pyramid.position, pyramid.surface)

          -- now try again to see if the pyramid on this surface has an underground
          Handler.on_post_surface_created({surface_index = pyramid.surface.index})
        end

        player.teleport(old_position, old_surface)
        global.pyramids_to_visit = {}

        if remote_view_to_restore then
          remote.call("space-exploration", "remote_view_start", remote_view_to_restore)
        end
      end
    end
  end

  if #global.pyramids_to_visit > 0 then return end
  script.on_event(defines.events.on_tick, nil)
end

function Ancient.zone_from_surface(surface)
  if not string.find(surface.name, "Vault ", 1, 1) then return end
  for zone_index in string.gmatch(surface.name, "Vault (%d+)") do
    return remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = tonumber(zone_index)})
  end
end

local colors = {
  ['productivity-module-9'] = 'red',
  ['speed-module-9']        = 'blue',
  ['effectivity-module-9']  = 'green',
}

function Handler.on_post_surface_created(event)
  local surface = game.get_surface(event.surface_index)

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  if not zone then return end

  if zone.type ~= "planet" then return end
  if zone.is_homeworld then return end

  -- if the module is taken, return the tint to the default :)
  local inside_surface_name = Ancient.vault_surface_name(zone)
  local inside_surface = game.get_surface(inside_surface_name)

  local color = 'white' -- default to un-tinted (e.g. no invisible pyramid if you scan a new surface while in sattelite mode)

  if not inside_surface then
    table.insert(global.pyramids_to_visit, zone.vault_pyramid)
    script.on_event(defines.events.on_tick, Handler.on_tick)
  else
    local container = inside_surface.find_entity('se-cartouche-chest', {0, -14})
    local inventory = container.get_inventory(defines.inventory.chest)

    for name, count in pairs(inventory.get_contents()) do
      color = colors[name] or color -- why would there be several tier 9's anyways?
    end
  end

  -- delete the old tinted pyramid (even thought it might already be the right color)
  local positionstr = util.positiontostr(zone.vault_pyramid.position)
  local tinted_pyramid = global.tinted_pyramid_at[positionstr]
  if tinted_pyramid and tinted_pyramid.valid then
    tinted_pyramid.destroy()
  end

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
