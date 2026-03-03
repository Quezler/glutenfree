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

mod.get_recipe_categories = function(recipe_prototype)
  local recipe_categories = recipe_prototype.additional_categories
  table.insert(recipe_categories, 1, recipe_prototype.category)
  return recipe_categories
end

mod.can_craft = function(entity_prototype, recipe_prototype)
  for _, recipe_category in ipairs(mod.get_recipe_categories(recipe_prototype)) do
    if entity_prototype.crafting_categories[recipe_category] then
      return true
    end
  end
end

mod.get_data = function()
  local data = {
    version = 1,
    crafting_machines = {},
  }

  for _, crafting_machine in pairs(prototypes.get_entity_filtered({{filter="crafting-machine"}})) do
    data.crafting_machines[crafting_machine.name] = {
      name = crafting_machine.name,
      recipes = {},
    }

    for _, recipe in pairs(prototypes.recipe) do
      if mod.can_craft(crafting_machine, recipe) then
        data.crafting_machines[crafting_machine.name].recipes[recipe.name] = true
      end
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

    local entity_prototype = prototypes.entity[crafting_machine.name]
    local entity_button = flow.add{
      type = "sprite-button",
      sprite = "entity/" .. crafting_machine.name,
      tooltip = crafting_machine.name,
      tags = {action = mod.prefix .. "open-factoriopedia", type = "entity", name = crafting_machine.name},
    }

    if entity_prototype.hidden then
      entity_button.style = "flib_slot_button_grey"
      entity_button.tooltip = entity_button.tooltip .. " (hidden)"
    end

    entity_button.tooltip = entity_button.tooltip .. "\n"
    for crafting_category, _ in pairs(entity_prototype.crafting_categories) do
      entity_button.tooltip = entity_button.tooltip .. "\n" .. crafting_category
    end

    -- can now no longer craft these
    for recipe_name, _ in pairs(storage.old_data.crafting_machines[crafting_machine.name].recipes) do
      if not storage.new_data.crafting_machines[crafting_machine.name].recipes[recipe_name] then
        local recipe_button = flow.add{
          type = "sprite-button",
          sprite = helpers.is_valid_sprite_path("recipe/" .. recipe_name) and "recipe/" .. recipe_name or "recipe/recipe-unknown",
          tooltip = recipe_name,
          style = "flib_slot_button_red",
          tags = {action = mod.prefix .. "open-factoriopedia", type = "recipe", name = recipe_name},
        }

        recipe_button.tooltip = recipe_button.tooltip .. "\n"
        for _, recipe_category in ipairs(mod.get_recipe_categories(prototypes.recipe[recipe_name])) do
          recipe_button.tooltip = recipe_button.tooltip .. "\n" .. recipe_category
        end
      end
    end

    -- can now craft these
    for recipe_name, _ in pairs(storage.new_data.crafting_machines[crafting_machine.name].recipes) do
      if not storage.old_data.crafting_machines[crafting_machine.name].recipes[recipe_name] then
        local recipe_button = flow.add{
          type = "sprite-button",
          sprite = helpers.is_valid_sprite_path("recipe/" .. recipe_name) and "recipe/" .. recipe_name or "recipe/recipe-unknown",
          tooltip = recipe_name,
          style = "flib_slot_button_green",
          tags = {action = mod.prefix .. "open-factoriopedia", type = "recipe", name = recipe_name},
        }
      end
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

script.on_event(defines.events.on_gui_click, function(event)
  local tags = event.element.tags
  if tags and tags["action"] == mod.prefix .. "open-factoriopedia" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.open_factoriopedia_gui(prototypes[tags.type][tags.name])
  end
end)
