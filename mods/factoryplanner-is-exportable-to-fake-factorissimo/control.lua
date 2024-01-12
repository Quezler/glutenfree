local print_gui = require('scripts.print_gui')

local function products(root)
  local products = {}
  for _, sprite_button in ipairs(root.children[2].children[2].children[1].children[1].children[2].children[1].children[1].children) do
    if sprite_button.sprite ~= "utility/add" then
      local left, right = sprite_button.sprite:match('([^/]+)/([^/]+)')
      table.insert(products, {type = left, name = right, amount = sprite_button.number})
    end
  end
  return products
end

local function byproducts(root)
  local byproducts = {}
  for _, sprite_button in ipairs(root.children[2].children[2].children[1].children[2].children[2].children[1].children[1].children) do
    local left, right = sprite_button.sprite:match('([^/]+)/([^/]+)')
    table.insert(byproducts, {type = left, name = right, amount = sprite_button.number})
  end
  return byproducts
end


local function ingredients(root)
  local ingredients = {}
  for _, sprite_button in ipairs(root.children[2].children[2].children[1].children[3].children[2].children[1].children[1].children) do
    local left, right = sprite_button.sprite:match('([^/]+)/([^/]+)')
    table.insert(ingredients, {type = left, name = right, amount = sprite_button.number})
  end
  return ingredients
end

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type ~= defines.gui_type.custom then return end
  if event.element.name ~= "fp_frame_main_dialog" then return end
  game.print(event.element.name)

  -- log(print_gui.serpent( event.element ))

  -- log(print_gui.path_to_caption(event.element, 'fp.pu_product', 'event.element')) -- event.element[2][2][1][1][1][1]

  -- log(print_gui.serpent( event.element.children[2].children[2].children[1].children[1] ))
  -- log(print_gui.serpent( event.element.children[2].children[2].children[1].children[1].children[2].children[1].children[1] ))

  log(serpent.line( products(event.element) ))

  -- log(print_gui.path_to_caption(event.element, 'fp.pu_ingredient', 'event.element')) -- event.element[2][2][1][1][1][1]

  -- log(print_gui.serpent( event.element.children[2].children[2].children[1].children[3] ))

  log(serpent.line( byproducts(event.element) ))
  log(serpent.line( ingredients(event.element) ))
end)
