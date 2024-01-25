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
  local position = entity.surface.find_non_colliding_position(entity.name, entity.position, 0, 1, true)
  local ghost = entity.surface.create_entity{
    name = 'entity-ghost',
    force = entity.force,
    position = position,
    inner_name = entity.name,
    create_build_effect_smoke = false,
  }

  -- ghost.tags = tags

  local _, revived, _ = ghost.revive()
  script.raise_script_revive({entity = revived, tags = tags})

  entity.copy_settings(revived, player)
  revived.destroy()
end

commands.add_command('reset-launch-trigger-to-manual', nil, function(command)
  local player = game.get_player(command.player_index)
  local selected = player.selected

  if selected and selected.name == Launchpad.name_rocket_launch_pad then

    local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
    if not (root and root.tags and root.tags.unit_number) then return end

    local trigger_dropdown = root.children[2].children[2]['trigger']
    local trigger_selected = trigger_dropdown.items[trigger_dropdown.selected_index][1]
    -- game.print(trigger_selected)

    if trigger_selected ~= "space-exploration.trigger-none" then

      log(print_gui.serpent(root.children[2].children[2]))

      local tags = {
        name = selected.surface.name,
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

      reset_launch_trigger_to_manual(selected, player, tags)
    end
  end
end)
