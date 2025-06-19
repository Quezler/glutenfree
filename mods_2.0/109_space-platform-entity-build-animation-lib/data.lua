require("shared")

local function any_feature_flag_enabled()
  for feature_flag, boolean in pairs(feature_flags) do
    if boolean then return true end
  end
end

local is_any_feature_flag_enabled = any_feature_flag_enabled()

local space_platform_entity_build_animations = require(mod_directory .. "/graphics/entity/space-platform-build-anim/entity-build-animations")

for corner, animations in pairs(space_platform_entity_build_animations) do
  for name, animation in pairs(animations) do
    animation.type = "animation"
    animation.name = string.format(mod_prefix .. "%s-%s", corner, name)
    if not is_any_feature_flag_enabled then
      for _, layer in ipairs(animation.layers) do
        layer.tint = {0, 0, 0, 0}
      end
    end
    data:extend{animation}
  end
end
