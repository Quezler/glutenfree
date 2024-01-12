local print_gui = require('scripts.print_gui')

local mod_prefix = 'fietff-'

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
  local root = player.opened
  assert(root.name == 'fp_frame_main_dialog')

  local items_per_timescale_button = root.children[2].children[2].children[2].children[1].children[9].children[1]
  assert(items_per_timescale_button.caption[2][1] == "fp.pu_item")
  if items_per_timescale_button.toggled == false then
    return player.create_local_flying_text{
      text = "Timescale must be set to items.", -- [items/s-m-h] so we can extract the doubles we need for math
      create_at_cursor = true,
    }
  end

  local products = get_item_box_contents(root, item_box_products)
  local byproducts = get_item_box_contents(root, item_box_byproducts)
  local ingredients = get_item_box_contents(root, item_box_ingredients)

  if #ingredients == 0 then
    return player.create_local_flying_text{
      text = "No ingredients defined at all.",
      create_at_cursor = true,
    }
  end

  for _, ingredient in ipairs(ingredients) do
    if ingredient.type == "entity" then
      return player.create_local_flying_text{
        text = "Mining drills are not supported.", -- it seems selecting pumpjacks does not allow for oil to be selected
        create_at_cursor = true,
      }
    end
  end
  
  local _table = table
  local table = root.children[2].children[2].children[2].children[3].children[1].children[1]
  local columns = {} -- [fp.pu_recipe, fp.pu_machine, fp.pu_beacon]
  for i, cell in ipairs(table.children) do -- the table has no rows, everything is a cell
    if cell.type ~= "label" then break end -- stop once we have all the column names
    columns[cell.caption[1]] = i -- thanks to preferences the amount & positions of columns can vary
  end

  local column_count = table_size(columns)
  local row_count = #table.children / (column_count + 1) -- + 1 for the horizontal flow

  for row = 2, row_count do
    local offset = (row-1) * (column_count + 1) -- don't question the +1, it just works
    local recipe = table.children[offset + columns['fp.pu_recipe']].children[2].sprite
    local machine = table.children[offset + columns['fp.pu_machine']].children[1].sprite

    local modules = {}
    for i = 2, #table.children[offset + columns['fp.pu_machine']].children do
      local module_button = table.children[offset + columns['fp.pu_machine']].children[i]
      if module_button.sprite ~= "utility/add" then
        _table.insert(modules, {module_button.sprite, module_button.number})
      end
    end

    log(serpent.line({recipe, machine, modules}))

    if #table.children[offset + columns['fp.pu_beacon']].children > 1 then -- 1 = supports beacons, 2+ = beacon and module(s) selected
      return player.create_local_flying_text{
        text = "Beacons are not supported.",
        create_at_cursor = true,
      }
    end
  end

  if player.clear_cursor() == false then
    return player.create_local_flying_text{
      text = "Failed to empty your hand.",
      create_at_cursor = true,
    }
  end

  player.cursor_stack.set_stack({name = mod_prefix .. 'item-1', count = 1})
  -- player.opened = nil
end)
