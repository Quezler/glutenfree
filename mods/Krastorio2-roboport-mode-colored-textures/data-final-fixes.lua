-- local orange_tint = {r = 0.5, g = 0.75, b = 0.5, a = 1}
-- local green_tint  = {r = 0.8, g = 1.0, b = 0.8, a = 1}

local green_tint = {r = 0.513, g = 0.849, b = 0.218, a = 1}
local orange_tint = {r = 0.948, g = 0.532, b = 0.20, a = 1}

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

for _, roboport in pairs(data.raw['roboport']) do
  local logistic = data.raw['roboport'][roboport.name .. '-logistic-mode']
  local construction = data.raw['roboport'][roboport.name .. '-construction-mode']

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

  ::continue::
end
