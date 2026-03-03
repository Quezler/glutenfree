local mod = {}

mod.name = "crafting-machine-recipes-migration-diff-inspector"
mod.prefix = mod.name .. "--"

mod.frame_name = mod.prefix .. "frame"

script.on_init(function()
  storage.old_data = nil
  storage.new_data = mod.get_data()
end)

script.on_configuration_changed(function()
  storage.old_data = storage.new_data
  storage.new_data = mod.get_data()
end)

mod.get_data = function()
  local data = {
    version = 1,
    crafting_machines = {},
    recipe_categories = {},
  }

  for _, crafting_machine in pairs(prototypes.get_entity_filtered({{filter="crafting-machine"}})) do
    data.crafting_machines[crafting_machine.name] = {
      name = crafting_machine.name,
      crafting_categories = crafting_machine.crafting_categories
    }
  end

  for _, recipe_category in pairs(prototypes.recipe_category) do
    data.recipe_categories[recipe_category.name] = {
      name = recipe_category.name,
      recipes = {}
    }
  end

  for _, recipe in pairs(prototypes.recipe) do
    local recipe_categories = recipe.additional_categories
    table.insert(recipe_categories, 1, recipe.category)

    for _, recipe_category in ipairs(recipe_categories) do
      data.recipe_categories[recipe_category].recipes[recipe.name] = {
        name = recipe.name,
      }
    end
  end

  return data
end

mod.open_gui = function(player)
  local frame = player.gui.screen[mod.frame_name]
  if frame then frame.destroy() end

  frame = player.gui.screen.add{
    type = "frame",
    name = mod.frame_name,
    direction = "vertical",
    caption = {"mod-name." .. mod.name},
  }
  frame.style.maximal_height = 500

  local inner = frame.add{
    type = "frame",
    name = "inner",
    style = "inside_shallow_frame",
    direction = "vertical",
  }
  frame.style.minimal_width = 1000

  local scroll_pane = inner.add{
    type = "scroll-pane",
    name = "scroll-pane",
    style = "deep_scroll_pane",
    vertical_scroll_policy = "always",
  }
  scroll_pane.style.minimal_width = frame.style.minimal_width - (8 * 3) - 12
  scroll_pane.style.maximal_width = frame.style.minimal_width - (8 * 3) - 12
  scroll_pane.style.minimal_height = frame.style.maximal_height - 80

  for _, crafting_machine in pairs(storage.new_data.crafting_machines) do
    if not storage.old_data.crafting_machines[crafting_machine.name] then goto continue end

    local flow = scroll_pane.add{
      type = "flow",
      -- name = recipe.name,
      style = "horizontal_flow",
    }

    local entity_button = flow.add{
      type = "sprite-button",
      sprite = "entity/" .. crafting_machine.name,
      tooltip = crafting_machine.name,
      -- tags = {action = mod_prefix .. "open-factoriopedia", type = "recipe", name = recipe.name},
    }

    if prototypes.entity[crafting_machine.name].hidden then
      entity_button.style = "flib_slot_button_grey"
    end

    for _, recipe_category in pairs(crafting_machine.crafting_categories) do
      -- bound to be messy
    end

    ::continue::
  end

  player.opened = frame
  frame.force_auto_center()
end

commands.add_command(mod.name, nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]

  if not storage.old_data then
    player.print("This world was not saved with this mod in it before.")
    return
  end

  mod.open_gui(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == mod.frame_name then
    event.element.destroy()
  end
end)
