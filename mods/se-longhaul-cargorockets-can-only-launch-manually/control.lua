local Launchpad = {name_rocket_launch_pad = 'se-rocket-launch-pad'}
local LaunchpadGUI = {name_rocket_launch_pad_gui_root = 'se-rocket-launch-pad-gui'}

--

local print_gui = require('scripts.print_gui')

function remove_rich_text(s) -- includes [color] blocks
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

local function reset_launch_trigger_to_manual(entity, player, tags)
  local position = entity.surface.find_non_colliding_position(entity.name, entity.position, 0, 1, false)
  local ghost = entity.surface.create_entity{
    name = 'entity-ghost',
    force = entity.force,
    position = position,
    inner_name = entity.name,
    create_build_effect_smoke = false,
  }

  -- not needed since the raise revive already takes it as an argument
  -- ghost.tags = tags

  local _, revived, _ = ghost.revive()
  -- if revived == nil then -- how and why does this happen?
  --   log(serpent.block({ entity.surface.name, position }))
  --   return
  -- end
  script.raise_script_revive({entity = revived, tags = tags})

  entity.copy_settings(revived, player)
  revived.destroy()
end

local function on_tick(event)
  for _, connected_player in ipairs(game.connected_players) do
    if connected_player.opened == nil then
      for unit_number, _ in pairs(global.structs_to_open) do
        -- global.structs_to_open[unit_number] = nil
        local struct = global.structs[unit_number]
        if struct.entity.valid == false then
          global.structs[unit_number] = nil
        else
          connected_player.opened = struct.entity -- not yet pvp compatible, there is no force check yet
        end
      end
      connected_player.opened = nil
      global.structs_to_open = {}
      script.on_event(defines.events.on_tick, nil)
      return
    end
  end
end

local function on_created_entity(event)
  local entity = event.created_entity or event.entity
  -- if event.tags and event.tags['exists_only_for_one_tick'] then return end

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity, -- container
  }

  global.structs_to_open[entity.unit_number] = true
  script.on_event(defines.events.on_tick, on_tick)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = Launchpad.name_rocket_launch_pad},
  })
end

script.on_init(function(event)
  global.structs = {}
  global.structs_to_open = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {Launchpad.name_rocket_launch_pad}})) do
      on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function(event)
  for unit_number, struct in pairs(global.structs) do
    global.structs_to_open[unit_number] = true
  end
end)

script.on_load(function(event)
  for unit_number, _ in pairs(global.structs_to_open) do
    script.on_event(defines.events.on_tick, on_tick)
    return
  end
end)

local function get_is_fuel_within_bounds(root)
  local fuel_progressbar = root.children[2].children[1]['fuel_capacity_progress']
  local fuel_k_string = fuel_progressbar.caption[2][3]
  if fuel_k_string == '?' then fuel_k_string = '0k' end
  local fuel_k = tonumber(fuel_k_string:sub(1, -2)) -- remove the k, then cast to number
  local fuel_within_bounds = 400 > fuel_k
  return fuel_within_bounds
end

local function on_gui_opened(event)
  if not event.entity then return end
  if event.entity.name ~= Launchpad.name_rocket_launch_pad then return end

  local player = game.get_player(event.player_index)

  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local fuel_within_bounds = get_is_fuel_within_bounds(root)

  local trigger_dropdown = root.children[2].children[2]['trigger']
  local trigger_selected = trigger_dropdown.items[trigger_dropdown.selected_index][1]

  trigger_dropdown.enabled = fuel_within_bounds
  if fuel_within_bounds == true then return end

  if trigger_selected ~= "space-exploration.trigger-none" then

    -- log(print_gui.serpent(root.children[2].children[1]))

    local tags = {
      name = event.entity.surface.name,
      launch_trigger = "none",
    }

    local destination_dropdown = root.children[2].children[2]['launchpad-list-zones']
    local destination_selected = destination_dropdown.items[destination_dropdown.selected_index]
    -- log(serpent.line(destination_selected)) -- {"space-exploration.any_landing_pad_with_name"} or "    [img=virtual-signal/se-planet] Nauvis"
    -- log(serpent.line(remove_rich_text(destination_selected))) -- Nauvis
    if #destination_selected > 1 then
      tags.zone_name = remove_rich_text(destination_selected)
    end

    local position_dropdown = root.children[2].children[2]['launchpad-list-landing-pad-names']
    local position_selected = position_dropdown.items[position_dropdown.selected_index]
    -- log(serpent.line(position_selected)) -- {"space-exploration.none_general_vicinity"} or "Nauvis Landing Pad"
    if #position_selected > 1 then
      tags.landing_pad_name = remove_rich_text(position_selected)
    end

    log(serpent.line(tags))

    -- tags.exists_only_for_one_tick = true
    reset_launch_trigger_to_manual(event.entity, player, tags)
  end
end

script.on_event(defines.events.on_gui_opened, on_gui_opened)

local function on_gui_selection_state_changed(event)
  if not (event.element and event.element.valid) then return end
  local element = event.element
  local player = game.get_player(event.player_index)
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  if element.name == "launchpad-list-zones" then
    local fuel_within_bounds = get_is_fuel_within_bounds(root)
    local trigger_dropdown = root.children[2].children[2]['trigger']

    -- we do not need to force the selected option to manual since SE does that for us when the zone changes
    trigger_dropdown.enabled = fuel_within_bounds
  end
end

script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
