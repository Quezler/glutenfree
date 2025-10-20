require("shared")

local mod_data = prototypes.mod_data[mod_prefix .. "recycling-recipe-name-to-original-recipe-name"].data

local function recipe_has_item_ingredient(recipe, ingredient_name)
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == "item" and ingredient.name == ingredient_name then
      return ingredient
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

  local lines = {}

  for _, item in pairs(prototypes.item) do
    local flow = scroll_pane.add{
      type = "flow",
      name = item.name,
      style = "horizontal_flow",
    }

    local line = {}

    local ingredient = flow.add{
      type = "sprite-button",
      sprite = "item/" .. item.name,
      tooltip = string.format("%s (%s)", item.name, item.type),
      tags = {action = mod_prefix .. "open-factoriopedia", type = "item", name = item.name},
    }

    if item.hidden or item.parameter then
      ingredient.style = "flib_slot_button_grey"
    end

    local recycling = prototypes.recipe[item.name .. "-recycling"]
    if not recycling then
      flow.add{
        type = "sprite-button",
        sprite = "virtual-signal/signal-no-entry",
        tooltip = "cannot be recycled",
      }
      table.insert(line, "!")
    else
      local arrow_button = flow.add{
        type = "sprite-button",
        sprite = "virtual-signal/right-arrow",
        tooltip = "recycles into",
        tags = {action = mod_prefix .. "open-factoriopedia", type = recycling.type, name = recycling.name},
      }
      ingredient.number = recycling.energy
      local source_recipe = mod_data[recycling.name] and prototypes.recipe[mod_data[recycling.name]] -- was it based on another recipe? (not self recycling)
      local seen_products = {}
      for _, product in ipairs(recycling.products) do
        seen_products[product.name] = true
        local number = (product.amount + (product.extra_count_fraction or 0)) * product.probability
        table.insert(line, string.format("%g × %s", number, product.name))
        local product_button = flow.add{
          type = "sprite-button",
          sprite = "item/" .. product.name,
          tooltip = string.format("%s (%s)", product.name, product.type),
          number = number,
          show_percent_for_small_numbers = true,
          tags = {action = mod_prefix .. "open-factoriopedia", type = "item", name = product.name},
        }

        if source_recipe then
          local ingredient_in_source_recipe = recipe_has_item_ingredient(source_recipe, product.name)
          if ingredient_in_source_recipe then
            -- if ingredient_in_source_recipe.amount / 4 ~= product_button.number then
            --   product_button.style = "flib_slot_button_yellow"
            -- else
            --   product_button.style = "flib_slot_button_green"
            -- end
            product_button.style = "flib_slot_button_green"
          else
            product_button.style = "flib_slot_button_red"
          end
        end
      end

      if source_recipe then
        for _, ingredient in ipairs(source_recipe.ingredients) do
          if seen_products[ingredient.name] == nil and ingredient.type == "item" then
            flow.add{
              type = "sprite-button",
              sprite = "item/" .. ingredient.name,
              tooltip = string.format("%s (%s)", ingredient.name, ingredient.type),
              tags = {action = mod_prefix .. "open-factoriopedia", type = "recipe", name = source_recipe.name},
              style = "flib_slot_button_orange",
            }
          end
        end
      end

    end

    table.insert(lines, item.name .. " -> " .. table.concat(line, ", "))
  end

  helpers.write_file("recycle-recipes-inspector.txt", table.concat(lines, "\n"), false, player.index)

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
