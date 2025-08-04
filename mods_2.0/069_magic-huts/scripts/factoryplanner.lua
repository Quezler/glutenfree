Factoryplanner = {}

local is_fp_frame_main_dialog = {
  ["fp_frame_main_dialog"] = true,
  ["factoryplanner_mainframe"] = true, -- https://mods.factorio.com/mod/GUI_Unifyer
}

function Factoryplanner.on_gui_opened(event)
  local root = event.element

  if not root then return end
  if not is_fp_frame_main_dialog[root.name] then return end

  -- game.print(LuaGuiPrettyPrint.path_to_caption(root, "fp.pu_factory", "root") or "nil")
  local factory_flow = root.children[2].children[2].children[1].children[2]
  local districts_view = not factory_flow.visible
  if districts_view then return end

  -- game.print(LuaGuiPrettyPrint.path_to_caption(root, "fp.pu_product", "root") or "nil")
  local item_boxes = root.children[2].children[2].children[3]
  local item_box_ingredients_label = item_boxes.children[1].children[1]

  if item_box_ingredients_label[mod_prefix .. "summon-magic-hut"] then return end
  local button = item_box_ingredients_label.add{
    type = "sprite-button",
    name = mod_prefix .. "summon-magic-hut",
    sprite = "entity/" .. mod_prefix .. "container-1",
    tooltip = {"fp.su_summon-magic-hut"},
    mouse_button_filter = {"left", "middle", "right"},
  }
  button.style.size = 24
  button.style.padding = -2
  button.style.left_margin = 4
end

local function get_root(element)
  local root = element
  while not is_fp_frame_main_dialog[root.name] do
    root = root.parent --[[@as LuaGuiElement]]
  end
  assert(root)
  return root
end

local function get_selected_factory(root)
  -- game.print(LuaGuiPrettyPrint.path_to_tag(root, "on_gui_click", "duplicate_factory", "root"))
  local factories = root.children[2].children[1].children[2].children[2].children[1]
  for _, factory in ipairs(factories.children) do
    if factory.children[2].toggled then
      return {
        name = factory.children[2].caption:gsub("^%[img=fp_trash_red%] ", ""),
        space_location = nil, -- nil means universal
        space_location_icon = "fp_universal_planet",

        -- multiply with prefix and prefix_to_multiplier before use
        power = 0,
        power_prefix = "",

        pollution = 0,
        pollution_prefix = "",

        entities = {},
        modules = {},
        recipes = {},

        products = {},
        byproducts = {},
        ingredients = {},
      }
    end
  end
end

local function split_class_and_name(sprite_path)
  return sprite_path:match('([^/]+)/([^/]+)')
end

local function get_item_box_contents(item_boxes, item_box_index)
  local sprite_buttons = item_boxes[item_box_index].children[2].children[1].children[1].children
  local any_fluids = false

  local contents = {}
  for _, sprite_button in ipairs(sprite_buttons) do
    if sprite_button.sprite ~= "utility/add" then
      local class, name = split_class_and_name(sprite_button.sprite)
      table.insert(contents, {type = class, name = name, count = sprite_button.number, quality = "normal"})
      if class == "fluid" then
        any_fluids = true
      end
    end
  end
  return contents, any_fluids
end

local function all_products_satisfied(item_boxes)
  local sprite_buttons = item_boxes[1].children[2].children[1].children[1].children

  for _, sprite_button in ipairs(sprite_buttons) do
    if sprite_button.sprite ~= "utility/add" then
      if sprite_button.style.name ~= "flib_slot_button_green" then
        return false
      end
    end
  end

  return true
end

local entity_type_blacklisted = util.list_to_map({
  "rocket-silo",
  "mining-drill",
  "offshore-pump",
})

local item_spoils = {}
for _, item in pairs(prototypes.item) do
  if item.get_spoil_ticks() > 0 then
    item_spoils[item.name] = true
  end
end

local recipe_requires_spoiling = {}
for _, recipe in pairs(prototypes.recipe) do
  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == "item" and item_spoils[ingredient.name] then
      recipe_requires_spoiling[recipe.name] = true
      goto next_recipe
    end
  end
  for _, product in ipairs(recipe.products) do
    if product.type == "item" and item_spoils[product.name] then
      recipe_requires_spoiling[recipe.name] = true
      goto next_recipe
    end
  end
  ::next_recipe::
end
-- log(serpent.block(recipe_requires_spoiling))

local function add_to_contents(contents, type_name_count_quality)
  for _, content in ipairs(contents) do
    if content.type == type_name_count_quality.type
    and content.name == type_name_count_quality.name
    and content.quality == type_name_count_quality.quality then
      content.count = content.count + type_name_count_quality.count
      return
    end
  end

  table.insert(contents, type_name_count_quality)
end

function prefix_to_multiplier(locale_key)
  local multiplier = 1
  local prefixes = {"kilo", "mega", "giga", "tera", "peta", "exa", "zetta", "yotta"}

  if locale_key == "" then
    return multiplier
  end

  for _, prefix in ipairs(prefixes) do
    multiplier = multiplier * 1000
    if "fp.prefix_" .. prefix == locale_key then
      return multiplier
    end
  end
end

local function check_recipe_is_allowed(player, recipe_name)
  local recipe = player.force.recipes[recipe_name]

  if not recipe then
    return false, string.format("Recipe \"%s\" not found.", recipe_name)
  end

  if not recipe.enabled then
    return false, string.format("Recipe \"%s\" not unlocked.", recipe_name)
  end

  if recipe.hidden then
    return false, string.format("Recipe \"%s\" is not visible.", recipe_name)
  end

  if recipe_requires_spoiling[recipe_name] then
    return false, string.format("Recipe \"%s\" has spoiling items.", recipe_name)
  end

  if prototypes.mod_data[mod_prefix .. "recipe-name-blacklisted"].data[recipe_name] then
    return false, string.format("Recipe \"%s\" has been blacklisted.", recipe_name)
  end

  return true
end

local function get_active_item_rate_view_button(root)
  for _, button in ipairs(root.children[2].children[2].children[1].children[6]["table_views"].children) do
    if button.toggled then
      return button
    end
  end
end

-- after adding the mod anyone who was on the districts page gets sent back to the main page (on_configuration_changed?),
-- in either case it means our magic button will always be initialized since even when switching it seems to persist fine.
function Factoryplanner.on_gui_click(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local root = get_root(event.element)

  local factory = get_selected_factory(root)
  if not factory then
    return player.create_local_flying_text{create_at_cursor = true, text = "no factory selected."}
  end

  factory.exported_by = player.name

  local sprite = root.children[2].children[1].children[1].children[1].children[4]
  if sprite.type == "sprite" then
    if sprite.sprite == "fp_universal_planet" then
      -- note: this is only when universal renders an icon, if there are no other surfaces it'll still be nil by default
      return player.create_local_flying_text{create_at_cursor = true, text = "universal factories are not allowed."}
    else
      factory.space_location = util.split(sprite.sprite, '/')[2]
      factory.space_location_icon = sprite.sprite
    end
  end

  local level = tonumber(root.children[2].children[2].children[4].children[1].children[1].children[3].caption[2][4])
  if level > 1 then
    return player.create_local_flying_text{create_at_cursor = true, text = "you must be on level 1."}
  end

  local item_boxes = root.children[2].children[2].children[3].children
  if not all_products_satisfied(item_boxes) then
    return player.create_local_flying_text{create_at_cursor = true, text = "not all products are 100% satisfied."}
  end

  local timescale = root.children[2].children[2].children[1].children[5].children[1].switch_state
  if timescale ~= "right" then
    return player.create_local_flying_text{create_at_cursor = true, text = "/minute is required."}
  end

  -- todo: the order is not guaranteed, and the button can even be hidden
  local active_item_rate_view_button = get_active_item_rate_view_button(root)
  if active_item_rate_view_button.caption[2][1] ~= "fp.pu_item" or active_item_rate_view_button.caption[4][1] ~= "fp.unit_minute" then
    return player.create_local_flying_text{create_at_cursor = true, text = "items/m is required."}
  end

  factory.products, products_have_fluids = get_item_box_contents(item_boxes, 1)
  factory.byproducts, byproducts_have_fluids = get_item_box_contents(item_boxes, 2)
  factory.ingredients, ingredients_have_fluids = get_item_box_contents(item_boxes, 3)
  -- game.print("products: " .. serpent.line(factory.products))
  -- game.print("byproducts: " .. serpent.line(factory.byproducts))
  -- game.print("ingredients: " .. serpent.line(factory.ingredients))

  if products_have_fluids or byproducts_have_fluids or ingredients_have_fluids then
    return player.create_local_flying_text{create_at_cursor = true, text = "use barrels to input or output fluids."}
  end

  factory.power = tonumber(root.children[2].children[2].children[1].children[2].children[2].children[1].tooltip[4][2])
  factory.power_prefix  =  root.children[2].children[2].children[1].children[2].children[2].children[1].tooltip[4][3][1] or ""

  local pollution_tooltip = assert(root.children[2].children[2].children[1].children[2].children[2].children[3].tooltip)
  if pollution_tooltip[1] == "fp.emissions_none" then
    factory.pollution = 0
    factory.pollution_prefix = ""
  else
    factory.pollution = tonumber(pollution_tooltip[3][2])
    factory.pollution_prefix  =  pollution_tooltip[3][3][1] or ""
  end

  -- log(string.format("%.3f %s (%d)", factory.power, factory.power_prefix, factory.power * prefix_to_multiplier(factory.power_prefix)))
  -- log(string.format("%.3f %s (%d)", factory.pollution, factory.pollution_prefix, factory.pollution * prefix_to_multiplier(factory.pollution_prefix)))

  local production_table = root.children[2].children[2].children[4].children[2].children[1]
  local production_table_column = {}
  local production_table_columns = 1 -- accounting for the empty-widget at the end of each row
  local production_table_children = production_table.children

  for i, cell in ipairs(production_table_children) do
    if cell.type ~= "label" then break end
    production_table_columns = production_table_columns + 1
    if type(cell.caption) == "table" then
      production_table_column[cell.caption[1]] = i
    end
  end

  local any_subfloors = false

  local production_table_rows = #production_table_children / production_table_columns
  for row = 2, production_table_rows do
    local offset = (row - 1) * production_table_columns

    local cell_recipe  = production_table_children[offset + production_table_column["fp.pu_recipe" ]]
    local cell_machine = production_table_children[offset + production_table_column["fp.pu_machine"]]

    local machine_style_name = cell_machine.children[1].style.name
    if machine_style_name == "flib_slot_button_pink_small" or machine_style_name == "flib_slot_button_purple_small" then
      return player.create_local_flying_text{create_at_cursor = true, text = "machines must not be limited."}
    end

    if cell_machine.children[1].sprite == "fp_generic_assembler" then
      any_subfloors = true
    end

    if cell_machine.children[1].sprite ~= "fp_generic_assembler" and cell_machine.children[1].number then -- skip factory floor headers
      local x_of_this_building = math.ceil(cell_machine.children[1].number)

      -- buildings
      local recipe_type, recipe_name = split_class_and_name(cell_recipe.children[1].sprite)
      local entity_type, entity_name = split_class_and_name(cell_machine.children[1].sprite)
      local entity_prototype = prototypes.entity[entity_name]
      entity_type = entity_prototype.type

      factory.recipes[recipe_name] = true

      if entity_type_blacklisted[entity_type] then
        return player.create_local_flying_text{create_at_cursor = true, text = entity_type .. "'s are blacklisted."}
      end

      if not entity_prototype.items_to_place_this then
        return player.create_local_flying_text{create_at_cursor = true, text = entity_name .. "s cannot be placed."}
      end
      local item_to_place_this = entity_prototype.items_to_place_this[1]
      add_to_contents(factory.entities, {
        type = "item",
        name = item_to_place_this.name,
        count = item_to_place_this.count * x_of_this_building,
        quality = cell_machine.children[1].quality.name,
      })

      -- modules
      for i = 2, #cell_machine.children do
        local module_button = cell_machine.children[i]
        if module_button.sprite ~= "utility/add" then
          local module_type, module_name = split_class_and_name(module_button.sprite)
          add_to_contents(factory.modules, {
            type = "item",
            name = module_name,
            count = module_button.number * x_of_this_building,
            quality = module_button.quality.name,
          })
        end
      end

      -- beacons
      local cell_beacons = production_table_children[offset + production_table_column["fp.pu_beacon"]]
      if #cell_beacons.children >= 2 then -- 1 = supports beacons, 2+ means beacon and modules selected
        return player.create_local_flying_text{create_at_cursor = true, text = "beacons are not allowed."}
      end

      -- recipe
      local recipe_is_allowed, recipe_is_not_allowed_reason = check_recipe_is_allowed(player, recipe_name)
      if not recipe_is_allowed then
        return player.create_local_flying_text{create_at_cursor = true, text = recipe_is_not_allowed_reason}
      end
    end

  end

  if any_subfloors then
    local show_all_subfloors_at_the_top_level = root.children[2].children[2].children[4].children[1].children[1].children[6].toggled
    if not show_all_subfloors_at_the_top_level then
      return player.create_local_flying_text{create_at_cursor = true, text = "all subfloors must be visible."}
    end
  end

  log(serpent.block(factory))
  local struct = Factories.add(factory)
  storage.playerdata[player.index].held_factory_index = struct.index

  local container_name = mod.mouse_button_to_container_name[event.button]
  local slots_required = #Buildings.get_filters_from_export(factory)
  local slots_available = prototypes.entity[container_name].get_inventory_size(defines.inventory.chest, "normal")

  player.pipette_entity(container_name, true)
  player.create_local_flying_text{
    text = string.format("[item=%s] %d/%d", container_name, slots_required, slots_available),
    create_at_cursor = true
  }
end

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local held_factory_index = storage.playerdata[event.player_index].held_factory_index
  if not held_factory_index then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if mod.player_holding_hut(player) then return end -- still holding a factory

  storage.playerdata[event.player_index].held_factory_index = nil
end)
