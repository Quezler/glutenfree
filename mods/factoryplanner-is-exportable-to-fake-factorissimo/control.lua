local print_gui = require('scripts.print_gui')

local item_box_products = 1
local item_box_byproducts = 2
local item_box_ingredients = 3

local function get_item_box_contents(root, item_box_index)
  local products = {}
  for _, sprite_button in ipairs(root.children[2].children[2].children[1].children[item_box_index].children[2].children[1].children[1].children) do
    if sprite_button.sprite ~= "utility/add" then
      local left, right = sprite_button.sprite:match('([^/]+)/([^/]+)')
      table.insert(products, {type = left, name = right, amount = sprite_button.number})
    end
  end
  return products
end

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type ~= defines.gui_type.custom then return end
  if event.element.name ~= "fp_frame_main_dialog" then return end
  local root = event.element

  game.print(root.name .. ' @ ' .. event.tick)

  -- log(print_gui.path_to_caption(root, 'fp.pu_product'   , 'root')) -- root.children[2].children[2].children[1].children[1].children[1].children[1]
  -- log(print_gui.path_to_caption(root, 'fp.pu_byproduct' , 'root')) -- root.children[2].children[2].children[1].children[2].children[1].children[1]
  -- log(print_gui.path_to_caption(root, 'fp.pu_ingredient', 'root')) -- root.children[2].children[2].children[1].children[3].children[1].children[1]

  -- log(print_gui.serpent( root ))
  -- log(print_gui.serpent( root.children[2].children[2].children[1] ))

  local ingredient_labels = root.children[2].children[2].children[1].children[item_box_products].children[1]
  if not ingredient_labels['ingredients_to_factorissimo'] then
    local button_factorissimo = ingredient_labels.add{
      name = "ingredients_to_factorissimo",
      type = "sprite-button",
      sprite = "entity/fietff-container-1",
      tooltip = {"fp.ingredients_to_factorissimo_tt"},
      mouse_button_filter = {"left"},
    }
    button_factorissimo.style.size = 24
    button_factorissimo.style.padding = -2
    button_factorissimo.style.left_margin = 4
  end

  log('products: ' .. serpent.line(get_item_box_contents(root, item_box_products)))
  log('byproducts: ' .. serpent.line(get_item_box_contents(root, item_box_byproducts)))
  log('ingredients: ' .. serpent.line(get_item_box_contents(root, item_box_ingredients)))
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name ~= "ingredients_to_factorissimo" then return end
  local player = game.get_player(event.player_index)

  player.create_local_flying_text{
    text = "Beacons are not supported.",
    create_at_cursor = true,
  }

  if player.clear_cursor() == false then
    player.create_local_flying_text{
      text = "Failed to empty your hand.",
      create_at_cursor = true,
    }
  end

  player.cursor_stack.set_stack({name = 'fietff-item-1', count = 1})
  player.opened = nil
end)
