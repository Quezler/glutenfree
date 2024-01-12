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
  game.print(event.element.name)

  -- log(print_gui.path_to_caption(event.element, 'fp.pu_product'     , 'event.element')) -- event.element[2][2][1][1][1][1]
  -- log(print_gui.path_to_caption(event.element, 'fp.pu_byingredient', 'event.element')) -- event.element[2][2][1][2][1][1]
  -- log(print_gui.path_to_caption(event.element, 'fp.pu_ingredient'  , 'event.element')) -- event.element[2][2][1][3][1][1]

  log(serpent.block({
    products = get_item_box_contents(event.element, item_box_products),
    byproducts = get_item_box_contents(event.element, item_box_byproducts),
    ingredients = get_item_box_contents(event.element, item_box_ingredients),
  }))
end)
