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
      }
    end
  end
end

local function get_class_and_name(sprite_path)
  return sprite_path:match('([^/]+)/([^/]+)')
end

local function get_item_box_contents(root, item_box_index)
  local sprite_buttons = root.children[2].children[2].children[3].children[item_box_index].children[2].children[1].children[1].children

  local contents = {}
  for _, sprite_button in ipairs(sprite_buttons) do
    if sprite_button.sprite ~= "utility/add" then
      local class, name = get_class_and_name(sprite_button.sprite)
      table.insert(contents, {type = class, name = name, amount = sprite_button.number, quality = "normal"})
    end
  end
  return contents
end

-- after adding the mod anyone who was on the districts page gets sent back to the main page (on_configuration_changed?),
-- in either case it means our magic button will always be initialized since even when switching it seems to persist fine.
function Factoryplanner.on_gui_click(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local root = get_root(event.element)

  local factory = get_selected_factory(root)
  game.print(serpent.line(factory))

  game.print(serpent.line(get_item_box_contents(root, 1), {sortkeys = false}))
  game.print(serpent.line(get_item_box_contents(root, 2), {sortkeys = false}))
  game.print(serpent.line(get_item_box_contents(root, 3), {sortkeys = false}))
end
