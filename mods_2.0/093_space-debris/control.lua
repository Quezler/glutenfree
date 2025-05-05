require("shared")

local mod = {}

script.on_init(function()
  storage.deathrattles = {}

  storage.platformdata = {}
  mod.refresh_platformdata()

  storage.space_location_data = {}
  mod.refresh_space_location_data()
end)

script.on_configuration_changed(function()
  mod.refresh_platformdata()
  mod.refresh_space_location_data()
end)

function mod.refresh_platformdata()
  -- deleted old
  for surface_index, platformdata in pairs(storage.platformdata) do
    if platformdata.surface.valid == false then
      storage.platformdata[surface_index] = nil
    else
      assert(platformdata.platform.valid)
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    if surface.platform then
      storage.platformdata[surface.index] = storage.platformdata[surface.index] or {
        surface = surface,
        platform = surface.platform,
        last_creation_tick = 0,

        -- it would be weird if we encountered items we've just ejected whilst traveling somewhere,
        -- so whilst in transit we're holding onto those items until another space location is closest.
        closest_space_location_name = mod.get_closest_space_location_name(surface.platform),
        ejected_items = {}, -- item_name -> item_count
      }
    end
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_platformdata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_platformdata)

function mod.refresh_space_location_data()
  -- old prototypes
  for space_location_name, _ in pairs(storage.space_location_data) do
    if not prototypes.space_location[space_location_name] then
      storage.space_location_data[space_location_name] = nil
    end
  end

  -- new prototypes
  for _, prototype in pairs(prototypes.space_location) do
    storage.space_location_data[prototype.name] = storage.space_location_data[prototype.name] or {
      name = prototype.name,
      items = {
        all = {},
        total = 0,
        names = {},
      }
    }
  end
end

function mod.refresh_items_cache(items)
  local total = 0
  local names = {}

  for item_name, item_amount in pairs(items.all) do
    total = total + item_amount
    table.insert(names, item_name)
  end

  items.total = total
  items.names = names
  log(serpent.line(items))
end

function mod.add_item_to_contents(item_name, contents)
  contents[item_name] = (contents[item_name] or 0) + 1
end

script.on_nth_tick(60 * 5, function(event)
  for _, platformdata in pairs(storage.platformdata) do
    local last_creation_tick = platformdata.last_creation_tick or 0
    platformdata.last_creation_tick = event.tick

    -- when at a space location or when the nearest space location changes then offload the ejected items table.
    -- note that this also means that stationairy platforms won't spawn any ejected items until their next cycle.
    local closest_space_location_name = mod.get_closest_space_location_name(platformdata.platform)
    if platformdata.platform.space_location or platformdata.closest_space_location_name ~= closest_space_location_name then
      local space_location_data = storage.space_location_data[platformdata.closest_space_location_name]
      local space_location_items_all = space_location_data.items.all

      -- log(string.format("ejected items from platform %s moved to space location %s:", platformdata.platform.name, platformdata.closest_space_location_name))
      -- log(serpent.line(platformdata.ejected_items))
      for item_name, item_amount in pairs(platformdata.ejected_items) do
        space_location_items_all[item_name] = (space_location_items_all[item_name] or 0) + item_amount
      end

      mod.refresh_items_cache(space_location_data.items)
      platformdata.ejected_items = {}
      platformdata.closest_space_location_name = closest_space_location_name
    end

    for _, ejected_item in ipairs(platformdata.platform.ejected_items) do
      if ejected_item.creation_tick > last_creation_tick then -- is > correct here? gotta close the 1 tick gap properly after all.
        local item_name = ejected_item.item.name.name -- item.name is an ItemPrototype apparently
        mod.add_item_to_contents(item_name, platformdata.ejected_items)
      end
    end
  end
end)

local ITEMS_PER_ASTEROID = 10

function mod.take_random_item(items)
  local item_name = items.names[math.random(1, #items.names)]
  items.all[item_name] = items.all[item_name] - 1

  if items.all[item_name] == 0 then
    items.all[item_name] = nil
    mod.refresh_items_cache(items) -- recompute item names
  else
    items.total = items.total - 1
  end

  return item_name
end

function mod.decorate_asteroid(asteroid, space_location_data)
  -- local space_location_items_all = space_location_data.items.all
  local items_total = space_location_data.items.total
  if ITEMS_PER_ASTEROID > items_total then
    return asteroid.destroy()
  end

  -- local item_names_count = #space_location_data.items.names

  local asteroid_data = {
    space_location_name = space_location_data.name, -- where to return the items to after no collision
    items = {},
  }
  for i = 1, ITEMS_PER_ASTEROID do
    local item_name = mod.take_random_item(space_location_data.items)
    asteroid_data.items[i] = item_name
    rendering.draw_sprite{
      sprite = "item/" .. item_name,
      x_scale = 0.5,
      y_scale = 0.5,
      target = asteroid,
      surface = asteroid.surface,
      orientation = math.random(),
      oriented_offset = {
        math.random() - 0.5,
        math.random() - 0.5,
      },
      orientation_target = asteroid,
      use_target_orientation = true,
    }
  end

  storage.deathrattles[script.register_on_object_destroyed(asteroid)] = asteroid_data

  -- /c game.player.selected.clone{position = {game.player.selected.position.x + math.random(), game.player.selected.position.y + math.random()}, surface = game.player.surface}
  -- if items_total > 1000 then
  --   asteroid.clone{
  --     position = asteroid.position,
  --     -- position = {
  --     --   asteroid.position.x + math.random(),
  --     --   asteroid.position.y + math.random(),
  --     -- },
  --     surface = asteroid.surface,
  --   }
  -- end

  asteroid.force = "neutral"
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= mod_name .. "-created" then return end
  local entity = event.target_entity --[[@as LuaEntity]]

  local platformdata = storage.platformdata[entity.surface.index]
  local space_location_data = storage.space_location_data[mod.get_closest_space_location_name(platformdata.platform)]

  -- log(serpent.line(space_location_data.items))
  mod.decorate_asteroid(entity, space_location_data)
end)

script.on_event(defines.events.on_entity_died, function(event) -- death through collision only
  storage.deathrattles[script.register_on_object_destroyed(event.entity)] = nil -- voids items
end, {
  {filter = "name", name = mod_name},
})

function mod.get_closest_space_location_name(platform)
  if platform.space_location then
    return platform.space_location.name
  end

  if 0.5 > platform.distance then
    return platform.space_connection.from.name
  else
    return platform.space_connection.to.name
  end
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    -- log(serpent.line(deathrattle))

    local ejected_items = storage.platformdata[deathrattle.space_location_name].ejected_items
    for _, item_name in ipairs(deathrattle.items) do
      mod.add_item_to_contents(item_name, ejected_items)
    end
  end
end)
