local print_gui = require('scripts.print_gui')
local Factory = require('scripts.factory')

local mod_prefix = 'fietff-'

local item_box_products = 1
local item_box_byproducts = 2
local item_box_ingredients = 3

local is_fp_frame_main_dialog = {
  ["fp_frame_main_dialog"] = true,
  ["factoryplanner_mainframe"] = true,
}

local function split_class_and_name(class_and_name)
  local class, name = class_and_name:match('([^/]+)/([^/]+)')
  assert(class)
  assert(name)
  return class, name
end

local function active_radio_button(buttons)
  for _, button in ipairs(buttons) do
    if button.toggled then return button end
  end
  error('none of the buttons are active')
end

local function prefix_to_multiplier(locale_key)
  local multiplier = 1
  local prefixes = {"kilo", "mega", "giga", "tera", "peta", "exa", "zetta", "yotta"}

  if locale_key == nil then
    return multiplier
  end

  for _, prefix in ipairs(prefixes) do
    if 'fp.prefix_' .. prefix == locale_key then
      return multiplier * 1000
    else
      multiplier = multiplier * 1000
    end
  end
end

local function merge_ingredients(ingredients, new_ingredient)
  for _, ingredient in ipairs(ingredients) do
    if ingredient.type == new_ingredient.type and ingredient.name == new_ingredient.name then
      ingredient.amount = ingredient.amount + new_ingredient.amount
      return
    end
  end
  table.insert(ingredients, new_ingredient)
end

local function get_item_box_contents(root, item_box_index)
  local products = {}
  for _, sprite_button in ipairs(root.children[2].children[2].children[1].children[item_box_index].children[2].children[1].children[1].children) do
    if sprite_button.sprite ~= "utility/add" then
      local class, name = split_class_and_name(sprite_button.sprite)
      table.insert(products, {type = class, name = name, amount = sprite_button.number})
    end
  end
  return products
end

local function all_item_boxes_are_green(root, item_box_index)
  local products = {}
  for _, sprite_button in ipairs(root.children[2].children[2].children[1].children[item_box_index].children[2].children[1].children[1].children) do
    if sprite_button.sprite ~= "utility/add" then
      if sprite_button.style.name ~= "flib_slot_button_green" then
        return false
      end
    end
  end
  return true
end

local function get_ingredient(ingredients, ingredient_type, ingredient_name)
  for i, ingredient in ipairs(ingredients) do
    if ingredient.type == ingredient_type and ingredient.name == ingredient_name then
      return ingredient, i
    end
  end
end

local get_factory_description = Factory.get_factory_description

script.on_event(defines.events.on_gui_opened, function(event)
  if event.gui_type ~= defines.gui_type.custom then return end
  if is_fp_frame_main_dialog[event.element.name] ~= true then return end
  local root = event.element

  -- game.print(root.name .. ' @ ' .. event.tick)

  -- log(print_gui.serpent( root.children[2].children[1].children[1].children[2] ))
  -- local factories = root.children[2].children[1].children[1].children[2].children
  -- local factory_name = active_radio_button(factories).caption[3]
  -- log(factory_name)
  
  -- log(print_gui.serpent( root.children[2].children[1].children[2].children[3].children[1].children[3] ))
  -- log(print_gui.path_to_tooltip(root, 'fp.timescale_tt', 'root'))

  local ingredient_labels = root.children[2].children[2].children[1].children[item_box_products].children[1]
  if not ingredient_labels['ingredients_to_factorissimo'] then
    local button_factorissimo = ingredient_labels.add{
      name = "ingredients_to_factorissimo",
      type = "sprite-button",
      sprite = "entity/fietff-container-1",
      tooltip = {"fp.ingredients_to_factorissimo_tt"},
      mouse_button_filter = {"left", "middle", "right"},
    }
    button_factorissimo.style.size = 24
    button_factorissimo.style.padding = -2
    button_factorissimo.style.left_margin = 4
  end
end)

script.on_event(defines.events.on_gui_click, function(event)
  if event.element.name ~= "ingredients_to_factorissimo" then return end
  local player = game.get_player(event.player_index)
  local root = player.opened
  if is_fp_frame_main_dialog[root.name] ~= true then
    log(print_gui.serpent(root))
    error(string.format("Played opened %s instead of fp_frame_main_dialog.", root.name))
  end

  local items_per_timescale_button = root.children[2].children[2].children[2].children[1].children[9].children[1]
  
  if items_per_timescale_button.caption == "" then
    return player.create_local_flying_text{
      text = "You must create a factory first.", -- `a check whether a factory is selected "should" come first, but who has none?` - Quezler
      create_at_cursor = true,
    }
  end
  
  assert(items_per_timescale_button.caption[2][1] == "fp.pu_item")
  if items_per_timescale_button.toggled == false then
    return player.create_local_flying_text{
      text = "Timescale must be set to items.", -- [items/s-m-h] so we can extract the doubles we need for math
      create_at_cursor = true,
    }
  end

  local clipboard = {
    tick = event.tick,
  }

  clipboard.products = get_item_box_contents(root, item_box_products)
  clipboard.byproducts = get_item_box_contents(root, item_box_byproducts)
  clipboard.ingredients = get_item_box_contents(root, item_box_ingredients)

  -- log('products: ' .. serpent.line(clipboard.products))
  -- log('byproducts: ' .. serpent.line(clipboard.byproducts))
  -- log('ingredients: ' .. serpent.line(clipboard.ingredients))

  if all_item_boxes_are_green(root, item_box_products) == false then
    return player.create_local_flying_text{
      text = "Not all products have a green background.",
      create_at_cursor = true,
    }
  end

  for _, ingredient in ipairs(clipboard.ingredients) do
    if ingredient.type == "entity" then
      return player.create_local_flying_text{
        text = "Mining drills are not supported.", -- it seems selecting pumpjacks does not allow for oil to be selected
        create_at_cursor = true,
      }
    end
  end

  local production_table = root.children[2].children[2].children[2].children[3].children[1].children[1]
  local columns = {} -- [fp.pu_recipe, fp.pu_machine, fp.pu_beacon]
  for i, cell in ipairs(production_table.children) do -- the table has no rows, everything is a cell
    if cell.type ~= "label" then break end -- stop once we have all the column names
    local caption = cell.caption[1]
    if caption == 'fp.info_label' then caption = caption .. cell.caption[2] end -- checkbox & percentage collide
    columns[caption] = i -- thanks to preferences the amount & positions of columns can vary
  end

  local column_count = table_size(columns) + 1 -- + 1 for the horizontal flow
  local row_count = #production_table.children / column_count

  clipboard.buildings = {}

  for row = 2, row_count do
    local offset = (row - 1) * column_count
    
    -- if the sprite ever changes into something else yet still doesn't have a `/` in it an assert will failsafe-block it
    if production_table.children[offset + columns['fp.pu_machine']].children[1].sprite == 'fp_generic_assembler' then
      return player.create_local_flying_text{
        text = "Subfloors are not supported.",
        create_at_cursor = true,
      }
    end

    local recipe_cell = production_table.children[offset + columns['fp.pu_recipe']].children[2]
    local machine_cell = production_table.children[offset + columns['fp.pu_machine']].children[1]

    if machine_cell.style.name == "flib_slot_button_pink_small" or machine_cell.style.name == "flib_slot_button_orange_small" then
      return player.create_local_flying_text{
        text = string.format("Limiting machines is not supported."),
        create_at_cursor = true,
      }
    end
    
    local recipe_class, recipe_name = split_class_and_name(recipe_cell.sprite)
    local machine_class, machine_name = split_class_and_name(machine_cell.sprite)
    local machine_count = math.ceil(production_table.children[offset + columns['fp.pu_machine']].children[1].number)

    local machine_prototype = game.entity_prototypes[machine_name]
    if machine_prototype.type == 'rocket-silo' or machine_prototype.type == 'offshore-pump' then
      return player.create_local_flying_text{
        text = string.format("Machines of type [%s] cannot be placed inside.", machine_prototype.type),
        create_at_cursor = true,
      }
    end
    
    local item_to_place_this = machine_prototype.items_to_place_this and machine_prototype.items_to_place_this[1] or nil -- placed by compound entities
    if item_to_place_this == nil then
      return player.create_local_flying_text{
        text = string.format("The [%s] machine has no building materials.", machine_name),
        create_at_cursor = true,
      }
    else
      machine_class = "item"
      machine_name = item_to_place_this.name
      machine_count = machine_count * (item_to_place_this.count or 1)
    end

    merge_ingredients(clipboard.buildings, {type = machine_class, name = machine_name, amount = machine_count})

    local modules = {}
    for i = 2, #production_table.children[offset + columns['fp.pu_machine']].children do
      local module_button = production_table.children[offset + columns['fp.pu_machine']].children[i]
      if module_button.sprite ~= "utility/add" then
        local module_class, module_name = split_class_and_name(module_button.sprite)
        -- table.insert(modules, {type = module_class, name = module_name, amount = module_button.number})
        merge_ingredients(clipboard.buildings, {type = module_class, name = module_name, amount = module_button.number * machine_count})
      end
    end

    -- log(serpent.line({recipe_name, machine_count .. 'x ' .. machine_name, modules}))

    if #production_table.children[offset + columns['fp.pu_beacon']].children > 1 then -- 1 = supports beacons, 2+ = beacon and module(s) selected
      return player.create_local_flying_text{
        text = "Beacons are not supported.",
        create_at_cursor = true,
      }
    end

    local force_recipe = player.force.recipes[recipe_name]
    if force_recipe == nil then
      -- todo: research impostor recipes, even though this just says "water", is "impostor water" even in the lua table?
      -- https://github.com/ClaudeMetz/FactoryPlanner/commit/516e2d75e1dbfb9278b4d9aa59e57923301ae29e
      return player.create_local_flying_text{
        text = string.format("Force has no recipe for [%s].", recipe_name),
        create_at_cursor = true,
      }
    end

    if force_recipe.enabled == false then -- wouldn't want players obtaining item outputs they shouldn't have unlocked yet (or cheaper recipes)
      return player.create_local_flying_text{
        text = string.format("Recipe [%s] not researched yet.", recipe_name),
        create_at_cursor = true,
      }
    end
  end

  do -- ensure all input/output fluids are barreled
    for i, product in ipairs(clipboard.products) do
      if product.type == "fluid" and global.can_be_barreled[product.name] then
        clipboard.products[i] = {
          type = "item",
          name = global.can_be_unbarreled_from[product.name],
          amount = product.amount / global.can_be_barreled[product.name],
        }
        merge_ingredients(clipboard.ingredients, {
          type = "item",
          name = global.can_be_barreled_with[product.name],
          amount = product.amount / global.can_be_barreled[product.name],
        })
      end
    end

    for i, byproduct in ipairs(clipboard.byproducts) do
      if byproduct.type == "fluid" and global.can_be_barreled[byproduct.name] then
        clipboard.byproducts[i] = {
          type = "item",
          name = global.can_be_unbarreled_from[byproduct.name],
          amount = byproduct.amount / global.can_be_barreled[byproduct.name],
        }
        merge_ingredients(clipboard.ingredients, {
          type = "item",
          name = global.can_be_barreled_with[byproduct.name],
          amount = byproduct.amount / global.can_be_barreled[byproduct.name],
        })
      end
    end
  
    for i, ingredient in ipairs(clipboard.ingredients) do
      if ingredient.type == "fluid" and global.can_be_unbarreled[ingredient.name] then
        clipboard.ingredients[i] = {
          type = "item",
          name = global.can_be_unbarreled_from[ingredient.name],
          amount = ingredient.amount / global.can_be_unbarreled[ingredient.name],
        }
        merge_ingredients(clipboard.byproducts, {
          type = "item",
          name = global.can_be_barreled_with[ingredient.name],
          amount = ingredient.amount / global.can_be_unbarreled[ingredient.name],
        })
      end
    end

    for _, foo in ipairs({clipboard.products, clipboard.byproducts, clipboard.ingredients}) do
      for _, bar in ipairs(foo) do
        if bar.type == "fluid" then
          return player.create_local_flying_text{
            text = string.format('There is no barrel for the [%s] fluid.', bar.name),
            create_at_cursor = true,
          }
        end
      end
    end

    -- todo: check if there are no duplicates in the products/byproducts/ingredients

    -- cancel out empty barrel ingredients & byproducts
    for by_product_to_equalize, _ in pairs(global.by_products_to_equalize) do
      local barrel_byproduct, i1 = get_ingredient(clipboard.byproducts, 'item', by_product_to_equalize)
      local barrel_ingredient, i2 = get_ingredient(clipboard.ingredients, 'item', by_product_to_equalize)

      if barrel_byproduct and barrel_ingredient then
        if barrel_byproduct.amount > barrel_ingredient.amount then
          barrel_byproduct.amount = barrel_byproduct.amount - barrel_ingredient.amount
          table.remove(clipboard.ingredients, i2)
        end
        if barrel_ingredient.amount > barrel_byproduct.amount then
          barrel_ingredient.amount = barrel_ingredient.amount - barrel_byproduct.amount
          table.remove(clipboard.byproducts, i1)
        end
      end
    end
  end

  if player.clear_cursor() == false then
    return player.create_local_flying_text{
      text = "Failed to empty your hand.",
      create_at_cursor = true,
    }
  end

  local factories = root.children[2].children[1].children[1].children[2].children
  clipboard.factory_name = active_radio_button(factories).caption[3]
  clipboard.factory_description = get_factory_description(clipboard)
  -- log(clipboard.factory_name)
  -- log(clipboard.factory_description)

  local energy_amount = tonumber(root.children[2].children[1].children[2].children[1].children[3].children[1].tooltip[2])
  local energy_prefix = root.children[2].children[1].children[2].children[1].children[3].children[1].tooltip[3][1] -- k/m/w (watt)
  clipboard.watts = energy_amount * prefix_to_multiplier(energy_prefix)
  -- log(clipboard.watts) -- /60 = number to put into electric energy interface usage (* for buffer)

  local pollution_per_minute = tonumber(root.children[2].children[1].children[2].children[1].children[3].children[3].tooltip[2])
  local pollution_per_minute_prefix = root.children[2].children[1].children[2].children[1].children[3].children[3].tooltip[3][1]
  clipboard.pollution = pollution_per_minute * prefix_to_multiplier(pollution_per_minute_prefix)
  -- log(clipboard.pollution)

  local timescale_buttons = root.children[2].children[1].children[2].children[3].children[1].children[3].children
  local timescale_button = active_radio_button(timescale_buttons)
  clipboard.timescale = timescale_button.caption[3][1] -- [fp.unit_second, fp.unit_minute, fp.unit_hours]
  -- log(clipboard.timescale)

  -- whilst i could simply go over the products/byproducts/ingredients and multiply or divide them by 60 (seconds or hours respectively), not right now.
  if clipboard.timescale ~= "fp.unit_minute" then
    return player.create_local_flying_text{
      text = "Timescale must be set to minutes.",
      create_at_cursor = true,
    }
  end

  local estimated_slot_requirement = 0
  + Factory.slots_required_for(clipboard.buildings)
  + Factory.slots_required_for(clipboard.products)
  + Factory.slots_required_for(clipboard.byproducts)
  + Factory.slots_required_for(clipboard.ingredients)

  local factory_item = mod_prefix .. 'item-1'
  if event.button == defines.mouse_button_type.middle then
    factory_item = mod_prefix .. 'item-2'
  end 
  if event.button == defines.mouse_button_type.right then
    factory_item = mod_prefix .. 'item-3'
  end

  if player.force.recipes[factory_item .. '-unlock'].enabled == false then
    return player.create_local_flying_text{
      text = "This factory tier is not yet researched.",
      create_at_cursor = true,
    }
  end

  -- close the gui only if the factory has enough slots
  local close_gui_after_grabbing_factory = global.inventory_size_from_item[factory_item] >= estimated_slot_requirement

  player.create_local_flying_text{
    text = string.format("[item=%s] %d/%d", factory_item, estimated_slot_requirement, global.inventory_size_from_item[factory_item]),
    create_at_cursor = true,
  }

  player.cursor_stack.set_stack({name = factory_item, count = 1}) -- give `RemoteView.get_stack_limit(stack)` more options for modders plox
  if close_gui_after_grabbing_factory then player.opened = nil end

  global.clipboards[player.index] = clipboard
  log(serpent.block(clipboard, {sortkeys = false}))
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Factory.on_created_entity, {
    {filter = 'name', name = mod_prefix .. 'container-1'},
    {filter = 'name', name = mod_prefix .. 'container-2'},
    {filter = 'name', name = mod_prefix .. 'container-3'},

    {filter = 'ghost_name', name = mod_prefix .. 'container-1'},
    {filter = 'ghost_name', name = mod_prefix .. 'container-2'},
    {filter = 'ghost_name', name = mod_prefix .. 'container-3'},
  })
end

local function get_fluid_amount_from_ingredients_or_products(entries)
  assert(#entries == 2) -- one barrel and one fluid, deviating from that norm requires enhancing this function

  for _, entry in ipairs(entries) do
    if entry.type == "fluid" then
      return entry.amount
    end
  end

  error('no fluid found.')
end

local function get_item_name_from_ingredients_or_products(entries)
  assert(#entries == 2) -- one barrel and one fluid, deviating from that norm requires enhancing this function

  for _, entry in ipairs(entries) do
    if entry.type == "item" then
      return entry.name
    end
  end

  error('no item found.')
end

local function on_configuration_changed(event)
  global.clipboards = global.clipboards or {}

  global.can_be_barreled = {}
  global.can_be_unbarreled = {}

  -- the commit that introduced this is likely to crash if a fluid has only one recipe (either unbarrel or barrel), will fix when reported.
  global.can_be_barreled_with = {}
  global.can_be_unbarreled_from = {}
  global.by_products_to_equalize = {}

  local cannot_be_barreled = {}
  local cannot_be_unbarreled = {}

  -- assume the recipes are like this, and that the research state of being able to barrel or unbarrel is insignificant
  -- todo: loop through all recipe names, determine the input and output values, determine the item name of the barrel.
  for fluid_name, fluid_prototype in pairs(game.fluid_prototypes) do
    local barrel_prototype = game.recipe_prototypes['fill-' .. fluid_name .. '-barrel']
    if barrel_prototype then
      -- log(serpent.block(barrel_prototype.ingredients))
      global.can_be_barreled[fluid_name] = get_fluid_amount_from_ingredients_or_products(barrel_prototype.ingredients)
      global.can_be_barreled_with[fluid_name] = get_item_name_from_ingredients_or_products(barrel_prototype.ingredients)
    else
      table.insert(cannot_be_barreled, fluid_name)
    end
    local unbarrel_prototype = game.recipe_prototypes['empty-' .. fluid_name .. '-barrel']
    if unbarrel_prototype then
      -- log(serpent.block(unbarrel_prototype.products))
      global.can_be_unbarreled[fluid_name] = get_fluid_amount_from_ingredients_or_products(unbarrel_prototype.products)
      assert(#unbarrel_prototype.ingredients == 1)
      assert(unbarrel_prototype.ingredients[1].type == 'item')
      global.can_be_unbarreled_from[fluid_name] = unbarrel_prototype.ingredients[1].name
    else
      table.insert(cannot_be_unbarreled, fluid_name)
    end
  end

  for fluid_name, barrel_name in pairs(global.can_be_barreled_with) do
    global.by_products_to_equalize[barrel_name] = true
  end

  log('are any of the 4 barrel sections deemed wrong? then this mod does not detect all of them properly:')
  log('can be barreled:')
  for fluid_name, fluid_amount in pairs(global.can_be_barreled) do
    log(string.format('- %d x %s', fluid_amount, fluid_name))
  end

  log('can be unbarreled:')
  for fluid_name, fluid_amount in pairs(global.can_be_unbarreled) do
    log(string.format('- %d x %s', fluid_amount, fluid_name))
  end

  log('cannot be barreled: ' .. table.concat(cannot_be_barreled, ', '))
  log('cannot be unbarreled: ' .. table.concat(cannot_be_unbarreled, ', '))

  global.structs = global.structs or {}
  global.deathrattles = global.deathrattles or {}

  global.inventory_size_from_item = {}
  global.inventory_size_from_item[mod_prefix .. 'item-1'] = game.entity_prototypes[mod_prefix .. 'container-1'].get_inventory_size(defines.inventory.chest)
  global.inventory_size_from_item[mod_prefix .. 'item-2'] = game.entity_prototypes[mod_prefix .. 'container-2'].get_inventory_size(defines.inventory.chest)
  global.inventory_size_from_item[mod_prefix .. 'item-3'] = game.entity_prototypes[mod_prefix .. 'container-3'].get_inventory_size(defines.inventory.chest)
end

local function on_load(event)
  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["dolly_moved_entity_id"] then
    script.on_event(remote.call("PickerDollies", "dolly_moved_entity_id"), Factory.on_dolly_moved_entity)
  end

  if remote.interfaces["PickerDollies"] and remote.interfaces["PickerDollies"]["add_blacklist_name"] then
    remote.call("PickerDollies", "add_blacklist_name", mod_prefix .. 'electric-energy-interface-' .. 1)
    remote.call("PickerDollies", "add_blacklist_name", mod_prefix .. 'electric-energy-interface-' .. 2)
    remote.call("PickerDollies", "add_blacklist_name", mod_prefix .. 'electric-energy-interface-' .. 3)
  end
end

script.on_init(function(event)
  on_configuration_changed(event)
  on_load(event)
end)

script.on_load(on_load)

script.on_configuration_changed(on_configuration_changed)

script.on_nth_tick(600, function(event)
  for unit_minute, struct in pairs(global.structs) do
    Factory.tick_struct(struct)
  end
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    for _, entity in ipairs(deathrattle) do
      entity.destroy()
    end
  end
end)

script.on_event(defines.events.on_entity_settings_pasted, Factory.on_entity_settings_pasted)
script.on_event(defines.events.on_player_setup_blueprint, Factory.on_player_setup_blueprint)
