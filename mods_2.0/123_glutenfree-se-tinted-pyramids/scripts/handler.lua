local Util = require("__space-exploration-scripts__.util")
local Ancient = require("__space-exploration-scripts__.ancient")
local Zonelist = require("__space-exploration-scripts__.zonelist")

--

local Handler = {}

function Handler.on_init()
  storage.next_tick_events = {}

  storage.tinted_pyramid_at = {}

  storage.pyramids_to_visit = {}

  storage.zone_index_to_color = {}

  for _, surface in pairs(game.surfaces) do
    Handler.on_post_surface_created({surface_index = surface.index})
  end
end

function Handler.on_load()
  if Handler.should_on_tick() then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end

  if storage.zone_index_to_color == nil then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end

function Handler.should_on_tick()
  return #storage.next_tick_events > 0 or #storage.pyramids_to_visit > 0
end

function Handler.on_surface_created(event)
  table.insert(storage.next_tick_events, event)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

function Handler.find_a_player_that_can_enter_pyramids()
  for _, player in ipairs(game.connected_players) do
    if player.character and not (player.driving or string.find(player.character.name, "jetpack", 1, true)) then
      return player
    end
  end
end

function Handler.on_tick(event)
  if storage.zone_index_to_color == nil then -- migration
    storage.zone_index_to_color = {}
    for _, surface in pairs(game.surfaces) do
      Handler.on_post_surface_created({surface_index = surface.index})
    end
  end

  local next_tick_events = storage.next_tick_events
  storage.next_tick_events = {}
  for _, e in ipairs(next_tick_events) do
    if e.name == defines.events.on_surface_created then Handler.on_post_surface_created(e) end
    if e.name == defines.events.on_gui_opened then Handler.on_post_gui_opened(e) end
  end

  if #storage.pyramids_to_visit > 0 then
    if #game.connected_players > 0 then
      local player = Handler.find_a_player_that_can_enter_pyramids()
      if player then
        -- game.print("yoink")
        local old_surface = player.surface
        local old_position = player.position

        for _, pyramid in ipairs(storage.pyramids_to_visit) do
          if pyramid.valid then
            player.teleport(pyramid.position, pyramid.surface)

            -- now try again to see if the pyramid on this surface has an underground
            Handler.on_post_surface_created({surface_index = pyramid.surface.index})
          end
        end

        player.teleport(old_position, old_surface)
        storage.pyramids_to_visit = {}
      else
        log("no player can enter a pyramid at tick ".. event.tick ..".")
      end
    end
  end

  if Handler.should_on_tick() then return end
  script.on_event(defines.events.on_tick, nil)
end

function Ancient.zone_from_surface(surface)
  if not string.find(surface.name, "Vault ", 1, true) then return end
  for zone_index in string.gmatch(surface.name, "Vault (%d+)") do
    return remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = tonumber(zone_index)})
  end
end

local colors = {
  ["productivity-module-9"] = "red",
  ["speed-module-9"]        = "blue",
  ["effectivity-module-9"]  = "green",
}

function Handler.on_post_surface_created(event)
  local surface = game.get_surface(event.surface_index) --[[@as LuaSurface]]

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = event.surface_index})
  if not zone then return end

  if zone.type ~= "planet" then return end
  if zone.is_homeworld then return end

  -- https://mods.factorio.com/mod/glutenfree-se-tinted-pyramids/discussion/65555c2f0106094c6fc67b8f
  -- TODO: why does this only crash on the "large" planetside ruin and not the "smaller" one?
  if not zone.glyph then return game.print(zone.name .. " has no glyph?") end

  -- if the module is taken, return the tint to the default :)
  local inside_surface_name = Ancient.vault_surface_name(zone)
  local inside_surface = game.get_surface(inside_surface_name)

  if not inside_surface then
    table.insert(storage.pyramids_to_visit, zone.vault_pyramid)
    script.on_event(defines.events.on_tick, Handler.on_tick)
    return
  end

  local container = assert(inside_surface.find_entity("se-cartouche-chest", {0, -14}))
  local inventory = assert(container.get_inventory(defines.inventory.chest))

  local color = "white" -- default to un-tinted
  for _, item in pairs(inventory.get_contents()) do
    color = colors[item.name] or color -- why would there be several tier 9's anyways?
  end

  -- delete the old tinted pyramid (even thought it might already be the right color)
  local positionstr = util.positiontostr(zone.vault_pyramid.position)
  local tinted_pyramid = storage.tinted_pyramid_at[positionstr]
  if tinted_pyramid and tinted_pyramid.valid then
    tinted_pyramid.destroy()
  end

  -- create the tinted pyramid
  local entity = surface.create_entity({
    name = zone.vault_pyramid.name .. "-tinted-" .. color,
    position = zone.vault_pyramid.position,
  })

  storage.tinted_pyramid_at[positionstr] = entity
  storage.zone_index_to_color[zone.index] = color
  log("tinted the pyramid on ".. surface.name .." ".. color ..".")
end

--

function Handler.on_player_fast_transferred(event)
  if event.entity.name ~= "se-cartouche-chest" then return end
  Handler.on_post_surface_created({surface_index = Ancient.zone_from_surface(event.entity.surface).surface_index})
end

function Handler.on_gui_closed(event)
  if not event.entity or event.entity.name ~= "se-cartouche-chest" then return end
  Handler.on_post_surface_created({surface_index = Ancient.zone_from_surface(event.entity.surface).surface_index})
end

function Handler.on_gui_opened(event)
  table.insert(storage.next_tick_events, event)
  script.on_event(defines.events.on_tick, Handler.on_tick)
end

function Handler.on_post_gui_opened(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  local root = Zonelist.get(player)
  if not root then return end

  local scroll_pane = Util.get_gui_element(root, Zonelist.path_list_rows_scroll_pane)
  if not scroll_pane then return end

  for _, row in pairs(scroll_pane.children) do
    if row.tags.zone_type == "planet" then
      local caption = row.row_flow.flags.caption

      -- check for the precense of the pyramid first since otherwise it would call remote view and teleport to each zone :o
      if string.find(caption, "se%-pyramid%-a") then
        local color = storage.zone_index_to_color[row.tags.zone_index]
        if color then
          row.row_flow.flags.caption = string.gsub(caption .. "", "se%-pyramid%-a]", "se-pyramid-a-tinted-" .. color .."]")
        else

          local surface = remote.call("space-exploration", "zone_get_make_surface", {zone_index = row.tags.zone_index})
          local render_distance = 32 * 8 -- pre render the spawn chunks as though a player pressed "view surface" themselves
          player.force.chart(surface, {{x = -render_distance, y = -render_distance}, {x = render_distance, y = render_distance}})
        end
      end
    end
  end
end

function Handler.on_gui_click(event)
  if not event.element.valid then return end

  -- player toggled any of the flags, not just the pyramid/vault one causes the caption to recompile
  if event.element.tags.action and event.element.tags.action == Zonelist.Flags.action_flag_button then
    -- game.print("Zonelist.update_zone_flags(player)")
    Handler.on_post_gui_opened({player_index = event.player_index})
  end
end

--

return Handler
