-- local orange_tint = {r = 0.5, g = 0.75, b = 0.5, a = 1}
-- local green_tint  = {r = 0.8, g = 1.0, b = 0.8, a = 1}

local green_tint = {r = 0.513, g = 0.849, b = 0.218, a = 1}
local orange_tint = {r = 0.948, g = 0.532, b = 0.20, a = 1}

local item_masks = {
  ["roboport"] = true,
}

-- local function lessen_tint(tint)
--   return {
--     r = 1 - (tint.r / 2),
--     g = 1 - (tint.g / 2),
--     b = 1 - (tint.b / 2),
--     a
--   }
-- end

-- green_tint = lessen_tint(green_tint)
-- orange_tint = lessen_tint(orange_tint)

local function set_animation_tint(animation, tint)
  if animation.layers then
    for _, layer in ipairs(animation.layers) do
      set_animation_tint(layer, tint)
      -- layer.frame_sequence = {6}
    end
    return
  end

  if animation then
    animation.tint = tint
  end

  if animation.hr_version then
    animation.hr_version.tint = tint
  end
end

local function add_tinted_mask_to_icon(mask_name, item_prototype, tint)
  assert(item_prototype.icon)
  assert(item_prototype.icons == nil)

  local mask_path = "__Krastorio2-roboport-mode-colored-textures__/graphics/icons/" .. mask_name .. ".png"

  item_prototype.icons = {
    {icon = item_prototype.icon},
    {icon = mask_path, tint = tint},
  }

  item_prototype.icon = nil
end

local function tint_existing_icon(item_prototype, tint)
  if item_prototype.icon == nil and item_prototype.icons == nil then
    return -- "big-electric-pole-roboport-logistic-mode"
  end
  assert(item_prototype.icon)
  assert(item_prototype.icons == nil)

  item_prototype.icons = {
    {icon = item_prototype.icon, tint = tint},
  }

  item_prototype.icon = nil
end

for _, roboport in pairs(data.raw["roboport"]) do
  local logistic = data.raw["roboport"][roboport.name .. "-logistic-mode"]
  local construction = data.raw["roboport"][roboport.name .. "-construction-mode"]

  -- log(roboport.name)
  -- log(serpent.line(logistic))
  -- log(serpent.line(construction))

  if logistic == nil or construction == nil then goto continue end
  log(roboport.name)

  -- logistic.door_animation_up.tint = orange_tint
  -- logistic.door_animation_up.hr_version.tint = logistic.door_animation_up.tint
  -- logistic.door_animation_down.tint = orange_tint
  -- logistic.door_animation_down.hr_version.tint = logistic.door_animation_down.tint
  set_animation_tint(logistic.door_animation_up, orange_tint)
  set_animation_tint(logistic.door_animation_down, orange_tint)

  -- construction.door_animation_up.tint = green_tint
  -- construction.door_animation_up.hr_version.tint = construction.door_animation_up.tint
  -- construction.door_animation_down.tint = green_tint
  -- construction.door_animation_down.hr_version.tint = construction.door_animation_down.tint
  set_animation_tint(construction.door_animation_up, green_tint)
  set_animation_tint(construction.door_animation_down, green_tint)

  set_animation_tint(logistic.base_animation, orange_tint)
  set_animation_tint(construction.base_animation, green_tint)

  if item_masks[roboport.name] then
    add_tinted_mask_to_icon(roboport.name .. "-mask", logistic, orange_tint)
    add_tinted_mask_to_icon(roboport.name .. "-mask", construction, green_tint)
  else
    tint_existing_icon(logistic, orange_tint)
    tint_existing_icon(construction, green_tint)
  end

  ::continue::
end
