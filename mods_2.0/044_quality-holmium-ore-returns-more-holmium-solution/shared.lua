local Shared = {}

function Shared.get_multiplier_for_quality(quality)
  return 1 * math.pow(2, quality.level)
end

return Shared