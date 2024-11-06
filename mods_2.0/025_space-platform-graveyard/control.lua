-- cancel_deletion()

-- local space_platform_max_size = {{-1000000, -200}, {1000000, 1000000}}
local space_platform_max_size = {{-1000, -1000}, {1000, 1000}}

script.on_event(defines.events.on_entity_died, function(event)
  if event.entity.name == "space-platform-hub" then
    game.print(event.entity.name)

    local surface = event.entity.surface
    local force = event.entity.force
    local position = event.entity.position

    event.entity.destroy()
    surface.create_entity{
      name = "space-platform-hub",
      force = force,
      position = position,
    }
    surface.platform.cancel_deletion()

    -- local player = game.players["Quezler"]

    -- player.cursor_stack.set_stack({name = "blueprint", count = 1})
    -- player.cursor_stack.create_blueprint{
    --   surface = event.entity.surface,
    --   force = event.entity.force,
    --   area = space_platform_max_size,
    --   always_include_tiles = true,
    -- }
  end
end)

script.on_event(defines.events.on_entity_damaged, function(event)
  if event.final_health == 0 then
    game.print("death?")
    event.entity.health = 1
    -- event.entity.health = 0
  end
end, {
  {filter = "type", type = "space-platform-hub"},
})
