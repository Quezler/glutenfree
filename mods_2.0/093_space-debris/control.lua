require("shared")

local mod = {}

script.on_init(function()
  storage.platformdata = {}
  mod.refresh_platformdata()

  storage.space_location_data = {}
  mod.refresh_space_location_data()
end)

script.on_configuration_changed(function()
  mod.refresh_platformdata()
  storage.space_location_data = {} -- todo: remove
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
      items = {}
    }
  end
end

script.on_nth_tick(60 * 5, function(event)
  for _, platformdata in pairs(storage.platformdata) do
    local last_creation_tick = platformdata.last_creation_tick or 0
    platformdata.last_creation_tick = event.tick

    if platformdata.platform.space_location then
      local space_location = storage.space_location_data[platformdata.platform.space_location.name]
      local space_location_items = space_location.items

      for _, ejected_item in ipairs(platformdata.platform.ejected_items) do
        if ejected_item.creation_tick > last_creation_tick then -- is > correct here? gotta close the 1 tick gap properly after all.
          local item_name = ejected_item.item.name.name -- item.name is an ItemPrototype apparently
          space_location_items[item_name] = (space_location_items[item_name] or 0) + 1
        end
      end
    end
  end
end)

function mod.cover_me_in_debris(asteroid)
  for i = 1, 10 do
    rendering.draw_sprite{
      sprite = "item/" .. "rail",
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
end

commands.add_command("cover-me-in-debris", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local selected = player.selected
  if selected then
    mod.cover_me_in_debris(selected)
  end
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= mod_name .. "-created" then return end
  local entity = event.target_entity --[[@as LuaEntity]]

  local platformdata = storage.platformdata[entity.surface.index]

  if platformdata.platform.space_location then
    local space_location = storage.space_location_data[platformdata.platform.space_location.name]
    local space_location_items = space_location.items
    log(serpent.line(space_location))
  end

  entity.force = "neutral" -- makes your turret unable to shoot "your own" dumped items
  mod.cover_me_in_debris(entity)
end)

script.on_event(defines.events.on_entity_died, function(event)
  game.print(serpent.line(event)) -- fires when colliding, not when it dies due to despawning
end, {
  {filter = "name", name = mod_name},
})
