local mod_name = "quality-upgrade-planner"

local function on_configuration_changed()
  for _, inventory in ipairs(game.get_script_inventories(mod_name)[mod_name]) do
    inventory.destroy()
  end
end

script.on_init(on_configuration_changed)
script.on_configuration_changed(on_configuration_changed)
