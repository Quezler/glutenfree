function string:startswith(start)
  return self:sub(1, #start) == start
end

local function handle_surface(surface)
  local platform = surface.platform
  if not platform then return end

  -- /c game.print(game.player.surface.platform.name)
  -- log(surface.name .. ' ' .. platform.name)

  -- local prefix = string.format("[color=1,1,1,0.%04d][/color]", surface.index)
  local surface_name_without_platform_hyphen = string.sub(surface.name, string.len("platform-") + 1)
  -- local prefix = string.format("[color=1,1,1,0.%04d][/color]", tonumber(surface_name_without_platform_hyphen))
  local decimal = string.format("%04d", tonumber(surface_name_without_platform_hyphen))
  local prefix = string.format("[color=1,1,1,0.%s][/color]", decimal)
  local detected_prefix = string.sub(platform.name, 1, string.len(prefix))

  if detected_prefix ~= prefix then
    -- in case the user added text to the front, search for our sorting markers further down in the string and kill them
    local platform_name = string.gsub(platform.name, "%[color=1,1,1,0%.".. decimal .. "%]%[/color%]", "")
    platform.name = prefix .. platform_name
    -- log(surface.name .. ' ' .. platform.name)
  end

  log(surface.name .. ' ' .. platform.name)
end

local function handle_surfaces()
  for _, surface in pairs(game.surfaces) do
    handle_surface(surface)
  end
end

script.on_init(function()
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

-- [color=1,1,1,0.990001][/color]
