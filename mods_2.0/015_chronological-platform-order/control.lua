function string:startswith(start)
  return self:sub(1, #start) == start
end

local function handle_surface(surface)
  local platform = surface.platform
  if not platform then return end

  local platform_name = platform.name

  -- we will allow the space platform graveyard mod to put a surface back in where it died
  if platform.space_location and platform.space_location.name == "space-platform-graveyard" then return end

  local decimal_v2 = string.format("%010d", tonumber(platform.index))
  local prefix = string.format("[color=1,1,1,0.%s][/color]", decimal_v2)
  local detected_prefix = string.sub(platform_name, 1, string.len(prefix))

  if detected_prefix ~= prefix then
    local surface_name_without_platform_hyphen = string.sub(surface.name, string.len("platform-") + 1)
    local decimal_v1 = string.format("%04d", tonumber(surface_name_without_platform_hyphen))

    -- in case the user added text to the front, search for our sorting markers further down in the string and kill them
    local platform_name = string.gsub(platform_name, "%[color=1,1,1,0%.".. decimal_v1 .. "%]%[/color%]", "")
    local platform_name = string.gsub(platform_name, "%[color=1,1,1,0%.".. decimal_v2 .. "%]%[/color%]", "")
    platform.name = prefix .. platform_name
  end

  -- log(surface.name  .. ' ' .. platform.name)
end

local function handle_surfaces()
  for _, surface in pairs(game.surfaces) do
    handle_surface(surface)
  end
end

script.on_init(function()
  handle_surfaces()
end)

script.on_configuration_changed(function()
  handle_surfaces()
end)

script.on_event(defines.events.on_surface_created, function(event)
  handle_surface(game.surfaces[event.surface_index])
end)

-- there is no hub renamed event
-- script.on_event(defines.events.on_surface_renamed, function(event)
--   handle_surface(game.surfaces[event.surface_index])
-- end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.entity then
    if event.entity.name == "space-platform-hub" then
      handle_surface(event.entity.surface)
    end
  end
end)
