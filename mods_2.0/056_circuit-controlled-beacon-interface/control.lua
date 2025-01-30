local mod_prefix = "circuit-controlled-beacon-interface--"

if script.active_mods["EditorExtensions"] then
  -- due to lack of a "starting items interface" for `items_to_add` like freeplay has, we'll just have to bodge it
  script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local inventory = player.get_inventory(defines.inventory.character_main) --[[@as LuaInventory]]
    if inventory.get_item_count("ee-super-substation") > 0 then -- detect whether "ee.set_loadout()" ran
      inventory.insert({name = mod_prefix .. "beacon", count = 20})
    end
  end)
end

-- the first 4 lines inside this function are paraphrased from the MIT licenced "Editor Extentions" mod by raiguard
script.on_event(defines.events.on_console_command, function (event)
  if event.command ~= "cheat" or not game.console_command_used then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  if event.parameters ~= "all" then return end

  local inventory = player.get_inventory(defines.inventory.character_main) --[[@as LuaInventory]]
  inventory.insert({name = mod_prefix .. "beacon", count = 20})
end)

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination
  -- remote.call("beacon-interface", "set_effects", entity.unit_number, {})
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = mod_prefix .. "beacon"},
  })
end
