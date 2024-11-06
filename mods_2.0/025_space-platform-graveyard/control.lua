script.on_init(function()
  storage.deathrattles = {}
end)

-- local space_platform_max_size = {{-1000000, -200}, {1000000, 1000000}}
local space_platform_max_size = {{-1000, -1000}, {1000, 1000}}

-- https://forums.factorio.com/120077
local function get_starter_pack_name(platform_hub)
  if platform_hub.name == "space-platform-hub" then return "space-platform-starter-pack" end
  error(string.format("no code yet to resolve the starter pack for %s.", platform_hub.name))
end

local function copy_hub_as_ghost(old_surface, new_surface)
  local inventory = game.create_inventory(1)
  inventory.insert({name = "blueprint"})
  inventory[1].create_blueprint{
    surface = old_surface,
    force = old_surface.platform.force,
    area = {{-1, -1}, {1, 1}}, -- the hub should be somewhere in the center
  }

  local blueprint_entities = inventory[1].get_blueprint_entities() or {}
  assert(#blueprint_entities == 1)

  local built_entities = inventory[1].build_blueprint{
    surface = new_surface,
    force = old_surface.platform.force,
    position = {0, 0},
  }
  inventory.destroy()

  assert(#built_entities == 1)
  return built_entities[1]
end

script.on_event(defines.events.on_entity_died, function(event)
  local platform = event.entity.surface.platform
  assert(platform)

  local space_platform = event.entity.force.create_space_platform{
    name = platform.name,
    planet = "space-platform-graveyard",
    starter_pack = get_starter_pack_name(event.entity), -- platform.hub is already nil on the platform
  }

  assert(space_platform)
  space_platform.apply_starter_pack()
  space_platform.schedule = platform.schedule

  local old_surface = event.entity.surface
  local new_surface = space_platform.surface

  old_surface.clone_area{
    source_area = space_platform_max_size,
    destination_area = space_platform_max_size,

    destination_surface = new_surface,
    destination_force = event.entity.force,

    clone_tiles = true,
    clone_entities = true,
    clone_decoratives = true,
    clear_destination_entities = true,
    clear_destination_decoratives = true,

    expand_map = true,
    create_build_effect_smoke = false,
  }

  local new_hub_ghost = copy_hub_as_ghost(old_surface, new_surface)
  storage.deathrattles[script.register_on_object_destroyed(new_hub_ghost)] = {platform = space_platform}

  for _, player in pairs(game.players) do
    if player.surface == old_surface and player.controller_type == defines.controllers.remote then
      player.set_controller{
        type = defines.controllers.remote,
        surface = new_surface,
      }
    end
  end
end, {
  {filter = "type", type = "space-platform-hub"},
})

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattle.platform.destroy(0)
  end
end)
