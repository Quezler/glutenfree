require("namespace")

---@param event EventData.CustomInputEvent
script.on_event(mod_prefix .. "fast-entity-transfer", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local selected = player.selected

  if selected and selected.type == "cargo-wagon" then
    -- if selected.train and selected.train.manual_mode and player.controller_type ~= defines.controllers.remote then
    --   return -- can transfer to the player's inventory instead
    -- end
    local inventory = selected.get_inventory(defines.inventory.cargo_wagon) --[[@as LuaInventory]]
    local stacks = selected.surface.spill_inventory{
      position = selected.position,
      inventory = inventory,
      -- enable_looted = true,
      force = selected.force,
      allow_belts = false,
      drop_full_stack = true,
    }

    player.create_local_flying_text{create_at_cursor = true, text = string.format("%d stacks spilled", #stacks)}
  end
end)
