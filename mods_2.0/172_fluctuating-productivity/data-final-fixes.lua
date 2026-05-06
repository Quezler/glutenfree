for _, technology in pairs(data.raw["technology"]) do
  for _, effect in ipairs(technology.effects or {}) do
    if effect.type == "change-recipe-productivity" then
      effect.change = 0
    end
  end

  for _, icon in ipairs(technology.icons or {}) do
    if icon.icon == "__core__/graphics/icons/technology/constants/constant-recipe-productivity.png" then
      icon.icon = "__fluctuating-productivity__/graphics/icons/technology/constants/constant-recipe-productivity-disabled.png"
    end
  end
end
