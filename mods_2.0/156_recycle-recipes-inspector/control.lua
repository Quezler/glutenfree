require("shared")

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

  for _, item in pairs(prototypes.item) do
    local flow = scroll_pane.add{
      type = "flow",
      name = item.name,
      style = "horizontal_flow",
    }

    local ingredient = flow.add{
      type = "sprite-button",
      sprite = "item/" .. item.name,
      tooltip = string.format("%s (%s)", item.name, item.type),
      tags = {action = mod_prefix .. "open-factoriopedia", type = item.type, name = item.name},
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
    else
      local arrow_button = flow.add{
        type = "sprite-button",
        sprite = "virtual-signal/right-arrow",
        tooltip = "recycles into",
        tags = {action = mod_prefix .. "open-factoriopedia", type = recycling.type, name = recycling.name},
      }
      ingredient.number = recycling.energy
      for _, product in ipairs(recycling.products) do
        local product_button = flow.add{
          type = "sprite-button",
          sprite = "item/" .. product.name,
          tooltip = string.format("%s (%s)", product.name, product.type),
          number = (product.amount + (product.extra_count_fraction or 0)) * product.probability,
          show_percent_for_small_numbers = true,
          tags = {action = mod_prefix .. "open-factoriopedia", type = product.type, name = product.name},
        }

        local product_prototype = prototypes.item[product.name]
        if product_prototype.hidden or product_prototype.parameter then
          product_button.style = "flib_slot_button_grey"
        end
      end
    end
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
