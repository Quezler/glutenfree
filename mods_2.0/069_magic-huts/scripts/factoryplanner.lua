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
    tooltip = {"fp.summon-magic-hut"},
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

  local contents = {}
  for _, sprite_button in ipairs(sprite_buttons) do
    if sprite_button.sprite ~= "utility/add" then
      local class, name = split_class_and_name(sprite_button.sprite)
      table.insert(contents, {type = class, name = name, amount = sprite_button.number, quality = "normal"})
    end
  end
  return contents
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

local function prefix_to_multiplier(locale_key)
  local multiplier = 1
  local prefixes = {"kilo", "mega", "giga", "tera", "peta", "exa", "zetta", "yotta"}

  if locale_key == nil then
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
    return false, string.format("Recipe \"%s\" not found.")
  end

  if not recipe.enabled then
    return false, string.format("Recipe \"%s\" not unlocked.")
  end

  if recipe.hidden then
    return false, string.format("Recipe \"%s\" is not visible.")
  end

  return true
end

local function get_quality_from_sprite_button(element)
  if element.tooltip == nil then
    return "normal" -- not hovered yet
  end

  if element.tooltip[2][1] == "fp.tt_title" then
    return "normal" -- not "fp.tt_title_with_note"
  end

  local quality_rich_text = element.tooltip[2][3][2] -- "[quality=legendary]"
  return string.sub(quality_rich_text, 10, -2)
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
  if not factory then return end
  -- game.print(serpent.line(factory))

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

  factory.products = get_item_box_contents(item_boxes, 1)
  factory.byproducts = get_item_box_contents(item_boxes, 2)
  factory.ingredients = get_item_box_contents(item_boxes, 3)
  -- game.print("products: " .. serpent_line(factory.products))
  -- game.print("byproducts: " .. serpent_line(factory.byproducts))
  -- game.print("ingredients: " .. serpent_line(factory.ingredients))

  local power = tonumber(root.children[2].children[2].children[1].children[2].children[2].children[1].tooltip[4][2])
  local power_prefix  =  root.children[2].children[2].children[1].children[2].children[2].children[1].tooltip[4][3][1]

  local pollution = tonumber(root.children[2].children[2].children[1].children[2].children[2].children[3].tooltip[3][2])
  local pollution_prefix  =  root.children[2].children[2].children[1].children[2].children[2].children[3].tooltip[3][3][1]

  -- game.print(string.format("%.3f %s (%d)", power, power_prefix, power * prefix_to_multiplier(power_prefix)))
  -- game.print(string.format("%.3f %s (%d)", pollution, pollution_prefix, pollution * prefix_to_multiplier(pollution_prefix)))

  -- log("power: " .. tostring(power))
  -- log("pollution: " .. tostring(pollution))

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

      local item_to_place_this = entity_prototype.items_to_place_this[1]
      add_to_contents(factory.entities, {
        type = "item",
        name = item_to_place_this.name,
        count = item_to_place_this.count * x_of_this_building,
        quality = get_quality_from_sprite_button(cell_machine.children[1]),
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
            quality = get_quality_from_sprite_button(module_button),
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

    -- LuaGuiPrettyPrint.dump(cell_recipe)
    -- LuaGuiPrettyPrint.dump(cell_machine)
  end

  if any_subfloors then
    local show_all_subfloors_at_the_top_level = root.children[2].children[2].children[4].children[1].children[1].children[6].toggled
    if not show_all_subfloors_at_the_top_level then
      return player.create_local_flying_text{create_at_cursor = true, text = "all subfloors must be visible."}
    end
  end

  log(serpent.block(factory, {sortkeys = false}))
end
