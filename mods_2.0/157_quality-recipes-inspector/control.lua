local util = require("util")

require("shared")

-- local function recipe_has_item_ingredient(recipe, ingredient_name)
--   for _, ingredient in ipairs(recipe.ingredients) do
--     if ingredient.type == "item" and ingredient.name == ingredient_name then
--       return ingredient
--     end
--   end
-- end

local function get_crafting_categories(recipe)
  local categories = recipe.additional_categories
  table.insert(categories, 1, recipe.category)
  return categories
end

local crafting_category_to_crafting_machines = {}
for _, prototype in pairs(prototypes.get_entity_filtered{{filter = "crafting-machine"}}) do
  for crafting_category, _ in pairs(prototype.crafting_categories) do
    crafting_category_to_crafting_machines[crafting_category] = crafting_category_to_crafting_machines[crafting_category] or {}
    if prototype.module_inventory_size > 0 then -- lets not care about entities with no module slots
      crafting_category_to_crafting_machines[crafting_category][prototype.name] = prototype
    end
  end
end

local gui_frame_name = mod_prefix .. "frame"

local function open_gui(player)
  local frame = player.gui.screen[gui_frame_name]
  if frame then frame.destroy() end

  frame = player.gui.screen.add{
    type = "frame",
    name = gui_frame_name,
    direction = "vertical",
    caption = {"mod-name." .. mod_name},
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

  local category_blacklist = util.list_to_map({
    "parameters", -- core
    "recycling", -- quality

    -- krastorio 2
    "kr-fuel-burning",
    "kr-void-crushing",
  })

  for _, recipe in pairs(prototypes.recipe) do
    if category_blacklist[recipe.category] then goto continue end

    local flow = scroll_pane.add{
      type = "flow",
      name = recipe.name,
      style = "horizontal_flow",
    }

    local recipe_button = flow.add{
      type = "sprite-button",
      sprite = "recipe/" .. recipe.name,
      tooltip = string.format("%s (%s)", recipe.name, recipe.type),
      tags = {action = mod_prefix .. "open-factoriopedia", type = "recipe", name = recipe.name},
    }

    local any_green = false
    local any_red = false

    if recipe.hidden or recipe.parameter then
      recipe_button.style = "flib_slot_button_grey"
    elseif recipe.allowed_effects and recipe.allowed_effects["quality"] then
      recipe_button.style = "flib_slot_button_green"
      any_green = true
    else
      recipe_button.style = "flib_slot_button_red"
      any_red = true
    end

    local speed_button = flow.add{
      type = "sprite-button",
      sprite = "virtual-signal/signal-speed",
      -- number = recipe.energy,
    }

    for _, crafting_category in ipairs(get_crafting_categories(recipe)) do
      for entity_name, entity in pairs(crafting_category_to_crafting_machines[crafting_category]) do
        local entity_button = flow.add{
          type = "sprite-button",
          sprite = "entity/" .. entity.name,
          tooltip = string.format("%s (%s)", entity.name, entity.type),
          tags = {action = mod_prefix .. "open-factoriopedia", type = entity.type, name = entity.name},
        }

        if entity.hidden then
          entity_button.style = "flib_slot_button_grey"
        elseif entity.allowed_effects and entity.allowed_effects["quality"] then
          entity_button.style = "flib_slot_button_green"
          any_green = true
        else
          entity_button.style = "flib_slot_button_red"
          any_red = true
        end
      end
    end

    if any_green == true and any_red == false then
      speed_button.style = "flib_slot_button_green"
    elseif any_green == false and any_red == true then
      speed_button.style = "flib_slot_button_red"
    elseif any_green == true and any_red == true then
      speed_button.style = "flib_slot_button_orange"
    end

    ::continue::
  end

  player.opened = frame
  frame.force_auto_center()
end

commands.add_command(mod_name, nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  open_gui(player)
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == gui_frame_name then
    event.element.destroy()
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  local tags = event.element.tags
  if tags and tags["action"] == mod_prefix .. "open-factoriopedia" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    player.open_factoriopedia_gui(prototypes[tags.type][tags.name])
  end
end)
