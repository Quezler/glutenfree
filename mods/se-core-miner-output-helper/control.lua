script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)
  local entity = player.selected

  if entity and entity.name == "se-core-miner-drill" and entity.mining_target then

    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
    local core_miners_on_this_surface = table_size(zone.core_mining)
    local fragment_name = entity.mining_target.prototype.mineable_properties.products[1].name
    local fragments_per_second = (entity.prototype.mining_speed / entity.mining_target.prototype.mineable_properties.mining_time) * entity.mining_target.amount / entity.mining_target.prototype.normal_resource_amount

    local text = {}
    text[1] = "[item="..fragment_name.."]"
    text[2] = math.floor(fragments_per_second * 10) / 10 .. "/s"
    text[3] = "+"
    text[4] = entity.force.mining_drill_productivity_bonus * 10 .. "0%"
    text[5] = "x"
    text[6] = core_miners_on_this_surface
    text[7] = "="
    text[8] = "[item="..fragment_name.."]"
    text[9] = string.format("%.2f/s", fragments_per_second * (1 + entity.force.mining_drill_productivity_bonus) * core_miners_on_this_surface)

    player.create_local_flying_text({text = table.concat(text, " "), position = entity.position})
  end

end)

--

local Util = require('__space-exploration-scripts__.util')
local Zonelist = require('__space-exploration-scripts__.zonelist')

function Zone_get_fragment_name(zone)
  if not (zone.type == "planet" or zone.type == "moon") then return end -- Zone.is_solid(zone)
  if zone.fragment_name then return zone.fragment_name end
  return "se-core-fragment-" .. zone.primary_resource
end

function Zone_get_core_seam_count(zone)
  local target_seams = 5 + 95 * (zone.radius / 10000)
  return target_seams -- effectively rounded down by the `for i = 1, target_seams do` loop
end

function get_mining_time(fragment_name)
  return game.entity_prototypes[fragment_name].mineable_properties.mining_time
end

function update_content_for_player(content, player, zone_index)
  local coremining_header = content["coremining-header"]
  local coremining = content.coremining

  -- grab the zone_index from the "View Surface" button
  if not zone_index then
    local button_flow = content.parent.parent[Zonelist.name_zone_data_bottom_button_flow]
    local view_button = button_flow[Zonelist.name_zone_data_view_surface_button]
    zone_index = view_button.tags.zone_index

    if view_button.tags.zone_type == "spaceship" then
      coremining_header.visible = false
      coremining.visible = false
      return
    end
  end

  local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = zone_index})
  if not zone then return end

  local fragment_name = Zone_get_fragment_name(zone) -- nil if not a planet or moon
  if not fragment_name then
    coremining_header.visible = false
    coremining.visible = false
    return
  else
    coremining_header.visible = true
    coremining.visible = not coremining_header.state and true or false
  end

  coremining.clear()

  local actual_core_miners = zone.core_mining and table_size(zone.core_mining) or 0 -- probably not pvp safe
  local mining_productivity = 1 + player.force.mining_drill_productivity_bonus
  local last_per_second = 0

  for i = 1, Zone_get_core_seam_count(zone) do
    local per_second = ((100 / get_mining_time(fragment_name)) * ((zone.radius + 5000) / 5000) * mining_productivity * i) / math.sqrt(i)

    local flow = coremining.add{
      type = "flow",
      direction = "horizontal"
    }

    flow.add{
      type = "label",
      caption = string.format("%03d", i),
      style = (actual_core_miners ~= i) and "se_zonelist_zone_data_label" or "se_zonelist_zone_data_label_link"
    }
    flow.add{
      type = "empty-widget",
      style = "se_relative_properties_spacer"
    }
    flow.add{
      type = "label",
      caption = string.format("%.2f/s",  per_second),
      tooltip = string.format("+%.2f/s", per_second - last_per_second),
      style = (actual_core_miners ~= i) and "se_zonelist_zone_data_value" or "se_zonelist_zone_data_value_link",
    }

    last_per_second = per_second
  end

  if zone.core_seam_positions then
    assert(table_size(zone.core_seam_positions) == math.floor(Zone_get_core_seam_count(zone)))
  end
end

script.on_event(defines.events.on_gui_opened, function(event)
  if not event.element then return end

  local container = nil
  local zone_index = nil

  if event.element.name == "se-map-view-zone-details" then
    container = event.element['right-flow']['container-frame']
    zone_index = event.element.tags.zone_index
  elseif event.element.name == Zonelist.name_root then
    local root = event.element

    local parent = Util.get_gui_element(root, Zonelist.path_zone_data_flow)
    if not parent then return end

    container = parent[Zonelist.name_zone_data_container_frame]
  else
    return -- a gui other than zonelist or star map planet detail
  end

  local content = container[Zonelist.name_zone_data_content_scroll_pane]

  if not content.coremining then
    content.add{
      type = "checkbox",
      name = "coremining-header",
      caption = {"space-exploration.zonelist-coremining-header"},
      state = false,
      tags = {action=Zonelist.action_zone_data_content_header, name="coremining"},
      style = "se_zonelist_zone_data_header_checkbox"
    }
    content.add{
      type = "flow",
      name = "coremining",
      direction = "vertical",
      style = "se_zonelist_zone_data_content_sub_flow"
    }
  else
    game.print('Gui element with name coremining-header already present in the parent element.')
  end

  local player = game.get_player(event.player_index)
  update_content_for_player(content, player, zone_index)
end)

script.on_event(defines.events.on_gui_click, function(event)
  if not event.element.valid then return end

  if event.element.tags and event.element.tags.action and event.element.tags.action == "go-to-zone" then
    -- todo: also check if the "se-map-view-zone-details" is open at all since "go-to-zone" sounds generic?
    local player = game.get_player(event.player_index)
    local container = event.element.parent.parent.parent['right-flow']['container-frame']
    local content = container[Zonelist.name_zone_data_content_scroll_pane]
    local zone_index = event.element.tags.zone_index
    update_content_for_player(content, player, zone_type)
    return
  end

  local player = game.get_player(event.player_index)

  local root = Zonelist.get(player)
  if not root then return end

  local parent = Util.get_gui_element(root, Zonelist.path_zone_data_flow)
  if not parent then return end

  local container = parent[Zonelist.name_zone_data_container_frame]
  local content = container[Zonelist.name_zone_data_content_scroll_pane]

  update_content_for_player(content, player, nil)
end)
