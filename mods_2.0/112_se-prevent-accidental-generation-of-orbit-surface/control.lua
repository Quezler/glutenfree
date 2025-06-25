script.on_event(defines.events.on_gui_click, function(event)
  -- if event.element.style ~= "se_remote_view_hierarchy_button" then return end
  if event.element.parent.name ~= "hierarchy-flow" then return end
  if event.element.tags.action ~= "go-to-zone" then return end -- ignore the interstellar map

  local surface_exists = remote.call("space-exploration", "zone_get_surface", {zone_index = event.element.tags.zone_index}) ~= nil
  if surface_exists == true then return end

  if event.shift == true then return end

  event.element.parent.add{
    type = "sprite-button",
    sprite = event.element.sprite,
    tooltip = event.element.tooltip,
    tags = event.element.tags,
    style = "se_remote_view_hierarchy_button",

    index = event.element.get_index_in_parent(),
  }

  event.element.destroy()

  game.get_player(event.player_index).create_local_flying_text{
    text = "Shift-click to generate surface.",
    create_at_cursor = true,
  }
end)
