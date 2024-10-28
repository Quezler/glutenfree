local mod_name = "quality-upgrade-planner"

local function set_mapper(upgrade_planner, i, entity_prototype, quality_prototype)
  upgrade_planner.set_mapper(i, "from", {type = "entity", name = entity_prototype.name})
  upgrade_planner.set_mapper(i, "to"  , {type = "entity", name = entity_prototype.name, quality = quality_prototype.name})
end

local function on_configuration_changed()
  for _, inventory in ipairs(game.get_script_inventories(mod_name)[mod_name]) do
    inventory.destroy()
  end

  -- /c game.player.opened = game.get_script_inventories("quality-upgrade-planner")["quality-upgrade-planner"][1]
  storage.inventory = game.create_inventory(1, "Quality upgrade planner")
  storage.inventory[1].set_stack({name = "quality-book", count = 1})

  local pages = storage.inventory[1].get_inventory(defines.inventory.item_main)
  assert(pages)

  for _, quality in pairs(prototypes.quality) do
    if quality.hidden then goto continue end -- quality-unknown
    -- game.print(quality.name)

    pages.insert({name = "upgrade-planner", count = 1})
    local upgrade_planner = pages[#pages]

    upgrade_planner.set_stack({name = "upgrade-planner", count = 1})
    upgrade_planner.preview_icons = {
      {
        index = 1,
        signal = {type = "quality", name = quality.name},
      }
    }
    upgrade_planner.label = quality.name:gsub("^%l", string.upper)

    local i = 1
    for _, entity in pairs(prototypes.entity) do
      local success, error = pcall(set_mapper, upgrade_planner, i, entity, quality)
      if success == false then log(error) end
      if success == true then i = i + 1 end
    end

    ::continue::
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)

commands.add_command("quality-upgrade-planner", "Receive a quality upgrade planner.", function(command)
  local player = game.get_player(command.player_index)
  assert(player)

  player.clear_cursor()
  if player.cursor_stack.valid_for_read == true then return end -- cursor not cleared?

  player.cursor_stack.set_stack(storage.inventory[1])
end)
