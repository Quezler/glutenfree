local mod_prefix = 'fietff-'

local FilterHelper = {}

FilterHelper.entity_type_supported = {
  ["loader-1x1"] = true,
  ["loader"] = true,
  ["inserter"] = true,
}

local function type_is_loader(type)
  if type == "loader-1x1" then return true end
  if type == "loader" then return true end
end

local function type_is_inserter(type)
  if type == "inserter" then return true end
end

local is_factory_building = {
  [mod_prefix .. 'container-1'] = true,
  [mod_prefix .. 'container-2'] = true,
  [mod_prefix .. 'container-3'] = true,
}

function FilterHelper.on_gui_opened(event)
  local player = game.get_player(event.player_index)
  assert(player)

  local entity = event.entity
  if entity == nil then return end
  if not FilterHelper.entity_type_supported[entity.type] then return end

  -- game.print('foo')

  local main_frame = player.gui.relative["main_frame"]
  -- game.print(main_frame == nil)
  if main_frame == nil then return end
  if main_frame.style.name ~= "fh_content_frame" then return end

  -- game.print(main_frame.valid)
  -- game.print("filter helper is active.")

  local content_frame = main_frame["content_frame"]
  local button_frame = content_frame["button_frame"]
  local button_table = button_frame["button_table"]

  -- game.print('bar')

  if type_is_loader(entity.type) then
    if entity.loader_type == "output" and entity.loader_container then
      if is_factory_building[entity.loader_container.name] then
        local struct = global.structs[entity.loader_container.unit_number]
        assert(struct)

        FilterHelper.override_buttons(button_table, FilterHelper.get_output_items(struct), FilterHelper.get_active_items(entity))
      end
    end
  elseif type_is_inserter(entity.type) then
    if entity.pickup_target and is_factory_building[entity.pickup_target.name] then
      local struct = global.structs[entity.pickup_target.unit_number]
      assert(struct)

      FilterHelper.override_buttons(button_table, FilterHelper.get_output_items(struct), FilterHelper.get_active_items(entity))
    end
    if entity.drop_target and is_factory_building[entity.drop_target.name] then
      local struct = global.structs[entity.drop_target.unit_number]
      assert(struct)

      FilterHelper.override_buttons(button_table, FilterHelper.get_input_items(struct), FilterHelper.get_active_items(entity))
    end
  else
    error(entity.type)
  end

  -- for _, button in ipairs(button_table.children) do
  --   game.print(serpent.line(button.tags))
  -- end
end

function FilterHelper.get_output_items(struct)
  local items = {}

  for _, product in ipairs(struct.clipboard.products) do
    if product.type == "item" then
      items[product.name] = "item/" .. product.name
    end
  end

  for _, byproduct in ipairs(struct.clipboard.byproducts) do
    if byproduct.type == "item" then
      items[byproduct.name] = "item/" .. byproduct.name
    end
  end

  return items
end

function FilterHelper.get_input_items(struct)
  local items = {}

  for _, ingredient in ipairs(struct.clipboard.ingredients) do
    if ingredient.type == "item" then
      items[ingredient.name] = "item/" .. ingredient.name
    end
  end

  return items
end

-- the code inside this function is pretty much a 1-1 copy from the filter helper mod and thus falls under their MIT license.
function FilterHelper.override_buttons(button_table, items, is_active_item)
  button_table.clear()

  local button_description = { "fh.tooltip-filters" }

  for name, sprite_name in pairs(items) do
    local button_style = (is_active_item[name] and "yellow_slot_button" or "recipe_slot_button")
    local action = (is_active_item[name] and "fh_deselect_button" or "fh_select_button")
    if game.is_valid_sprite_path(sprite_name) then
        button_table.add {
            type = "sprite-button",
            sprite = sprite_name,
            tags = {
                action = action,
                item_name = name ---@type string
            },
            tooltip = { "fh.button-tooltip", game.item_prototypes[name].localised_name, button_description },
            style = button_style,
            mouse_button_filter = { "left", "right", "middle" },
        }
    end
  end
end

function FilterHelper.get_active_items(entity)
  local active_items = {}
  for i = 1, entity.filter_slot_count do
    local filter = entity.get_filter(i)
    if filter then
      active_items[filter] = true
    end
  end
  return active_items
end

-- function FilterHelper.on_nth_tick_60(event)
--   for _, player in pairs(game.players) do
--     -- if player.opened then game.print(player.opened.type) end
--     if player.opened then
--       game.print(serpent.line({game.tick, player.opened.type}))
--     else
--       game.print(serpent.line({game.tick, player.opened}))
--     end
    
--     if player.opened and FilterHelper.entity_type_supported[player.opened.type] then
--       FilterHelper.on_gui_opened({player_index = player.index, entity = player.opened})
--     end
--   end
--   -- game.print(game.tick % 60)
-- end

return FilterHelper
