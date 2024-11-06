-- cancel_deletion()

-- local space_platform_max_size = {{-1000000, -200}, {1000000, 1000000}}
local space_platform_max_size = {{-1000, -1000}, {1000, 1000}}

-- https://forums.factorio.com/120077
local function get_starter_pack_name(platform_hub)
  if platform_hub.name == "space-platform-hub" then return "space-platform-starter-pack" end
  error(string.format("no code yet to resolve the starter pack for %s.", platform.hub.name))
end

script.on_event(defines.events.on_entity_died, function(event)
  if event.entity.name == "space-platform-hub" then
    -- game.print(event.entity.name)

    -- local surface = event.entity.surface
    -- local force = event.entity.force
    -- local position = event.entity.position

    -- event.entity.destroy()
    -- surface.create_entity{
    --   name = "space-platform-hub",
    --   force = force,
    --   position = position,
    -- }
    -- surface.platform.cancel_deletion()

    -- local player = game.players["Quezler"]

    -- player.cursor_stack.set_stack({name = "blueprint", count = 1})
    -- player.cursor_stack.create_blueprint{
    --   surface = event.entity.surface,
    --   force = event.entity.force,
    --   area = space_platform_max_size,
    --   always_include_tiles = true,
    -- }

    local platform = event.entity.surface.platform
    assert(platform)

    local space_platform = event.entity.force.create_space_platform{
      name = platform.name,
      planet = "space-platform-graveyard",
      starter_pack = get_starter_pack_name(event.entity), -- .hub is already nil on the platform
    }

    assert(space_platform)
    space_platform.apply_starter_pack()
  end
end)

-- script.on_event(defines.events.on_entity_damaged, function(event)
--   if event.final_health == 0 then
--     game.print("death?")
--     event.entity.health = 1
--     -- event.entity.health = 0
--   end
-- end, {
--   {filter = "type", type = "space-platform-hub"},
-- })
