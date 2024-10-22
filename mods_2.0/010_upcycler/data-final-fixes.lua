for _, module in pairs(data.raw["module"]) do
  if module.effect.quality ~= nil then

    -- hide modules that have possitive quality
    if module.effect.quality > 0 then
      module.hidden = true
      data.raw["recipe"][module.name].hidden = true
    end

    -- and set both positive and negative qualities to nil
    module.effect.quality = nil
  end
end
