local function try_to_give_player_personal_roboport(player)
  local armorslot = player.get_inventory(defines.inventory.character_armor)

  -- armorslot can be nil whilst the player is in remote view
  if armorslot and armorslot.is_empty() then
    -- not valid whilst there's a hand in their pants
    if armorslot.insert({name = "empty-ish-armor-slot"}) and armorslot[1].valid_for_read then
      armorslot[1].grid.put{name = "disposable-roboport-equipment"}
    end

  end
end

script.on_event(defines.events.on_player_crafted_item, function(event)
  if event.item_stack.valid_for_read == false then return end
  if event.item_stack.name ~= "disposable-construction-robot" then return end

  local player = game.get_player(event.player_index)

  try_to_give_player_personal_roboport(player)
end)

-- prevent players from ctrl clicking it into their main inventory,
-- unfortunately doesn't work when you grab it with your hand.
script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  local player = assert(game.get_player(event.player_index))

  player.get_inventory(defines.inventory.character_main).remove({name = "empty-ish-armor-slot"})
  if player.cursor_stack.valid_for_read and player.cursor_stack.name == "empty-ish-armor-slot" then player.cursor_stack.clear() end

  -- commented out since the hand cannot easily be dealt with, and it refreshes when you craft new bots anyways.
  -- try_to_give_player_personal_roboport(player)
end)

-- this doesn't need to save-load for multiplayer compatibility since it only applies to the current tick right?
local ignored = {}

-- a hack to only spoil 1 item each time spoil triggers #tool-durability
script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "disposable-construction-robot-spoiled" then return end

  if event.source_entity and event.source_entity.type == "character" and event.source_entity.player then
    local player = event.source_entity.player --[[@as LuaPlayer]]
    local cache_key = event.tick .. '-' .. player.index

    if ignored[cache_key] == nil then
      ignored[cache_key] = true

      local armor = player.get_inventory(defines.inventory.character_armor)
      if armor and armor[1].valid_for_read and armor[1].name ~= "empty-ish-armor-slot" then
        return -- refund everything by default, but if the player *wears* any armor other than the empty ish slot: minus one.
      end
    end

    event.source_entity.get_inventory(defines.inventory.character_main).insert({name = "disposable-construction-robot"})
  end
end)
