local Zone = require('scripts.zone')

local launchpad = {}

function launchpad.init()
  global.entries = {}
  global.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-rocket-launch-pad'})) do

      launchpad.register_silo(entity)
    end
  end

  global.has_opened_every_silo = false
end

function launchpad.on_configuration_changed()
  global.has_opened_every_silo = false
end

function launchpad.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= 'se-rocket-launch-pad' then return end

  launchpad.register_silo(entity)
end

function launchpad.register_silo(entity)
  global.entries[entity.unit_number] = {
    unit_number = entity.unit_number,
    container = entity,
    label = nil,
  }
end

function get_child(parent, name)
  for i = 1,  #parent.children_names do
    if parent.children_names[i] == name then
      return parent.children[i]
    end
  end

  error('could not find a child named ['.. name ..'].')
end

-- remove leading whitespace from string.
function ltrim(s)
  return (s:gsub("^%s*", ""))
end

function remove_rich_text(s)
  local words = {}

  -- split at each space
  for word in s:gmatch("%S+") do
    if word:sub(1, 1) == '[' or word:sub(-1, -1) == ']' then
      -- ignore
    else
      table.insert(words, word)
    end
  end

  return table.concat(words, ' ')
end

function launchpad.on_gui_opened(event)
  if not event.entity then return end
  if event.entity.name ~= 'se-rocket-launch-pad' then return end

  local player = game.get_player(event.player_index)

  -- after an update, have a player open every silo so we can get all fresh values
  if not global.has_opened_every_silo then
    global.has_opened_every_silo = true

    local shifu = player.opened
    player.opened = nil
    for _, entry in pairs(global.entries) do
      if entry.container.valid then
        player.opened = entry.container
      else
        global.entries[_] = nil
      end
    end
    player.opened = shifu
  else
    local container = get_child(player.gui.relative, 'se-rocket-launch-pad-gui')
    local launchpad_gui_frame = container.children[2] -- style = inside_shallow_frame
    local launchpad_gui_inner = get_child(launchpad_gui_frame, 'launchpad_gui_inner')

    local zones_dropdown = get_child(launchpad_gui_inner, 'launchpad-list-zones')
    local selected = launchpad.get_destination(zones_dropdown)

    launchpad.update_by_unit_number(event.entity.unit_number, selected)
  end
end

function launchpad.on_gui_selection_state_changed(event)
  if event.element.name ~= 'launchpad-list-zones' then return end

  local unit_number = event.element.parent.parent.parent.tags.unit_number
  if not unit_number then error('could not get this silo\'s unit number.') end

  launchpad.update_by_unit_number(unit_number, launchpad.get_destination(event.element))
end

function launchpad.get_destination(zones_dropdown)
  local selected = zones_dropdown.items[zones_dropdown.selected_index]

  if selected[1] == "space-exploration.any_landing_pad_with_name" then selected = nil end

  -- "        [img=virtual-signal/se-planet-orbit] Nauvis Orbit"
  if selected ~= nil then selected = ltrim(selected) end

  if selected ~= nil then
    local zone = remote.call("space-exploration", "get_zone_from_name", {zone_name = remove_rich_text(selected)})

    -- game.print(serpent.block( zone ))

    local icon = zone.primary_resource

    -- because these make sense to me personally
    if zone.name == 'Nauvis' then icon = 'landfill' end
    if zone.name == 'Nauvis Orbit' then icon = 'satellite' end

    -- if zone.type == 'orbit' then
    -- end
    -- print(serpent.block( zone ))
    -- game.print(zone.parent.type)

    local rich_text = '[item=' .. icon .. ']'

    if zone.type == 'orbit' then
      rich_text = '[img=' .. Zone.get_icon(zone) .. ']'
    end

    selected = rich_text .. ' ' .. zone.name
  end

  return selected
end

function launchpad.update_by_unit_number(unit_number, destination)
  local entry = global.entries[unit_number]

  if entry.label then
    entry.label.destroy()
    entry.label = nil
  end

  if destination == nil then return end

  -- entry.label = rendering.draw_text({
  --   text = destination,
  --   color = {1, 1, 1},
  --   surface = entry.container.surface,
  --   target = entry.container,
  --   target_offset = {0, 1.6},
  --   alignment = 'center',
  -- })

  local position = entry.container.position
  position.y = position.y + 1.9

  entry.label = entry.container.surface.create_entity{name = 'hovering-text', position = position, text = destination}
  global.deathrattles[script.register_on_entity_destroyed(entry.container)] = {entry.label}
end

function launchpad.on_entity_destroyed(event)
  if not global.deathrattles[event.registration_number] then return end

  for _, entity in ipairs(global.deathrattles[event.registration_number]) do
    entity.destroy()
  end

  global.deathrattles[event.registration_number] = nil
end

return launchpad
