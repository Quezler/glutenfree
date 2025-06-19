require("shared")

local space_platform_entity_build_animations = require(mod_directory .. "/graphics/entity/space-platform-build-anim/entity-build-animations")

for corner, animations in pairs(space_platform_entity_build_animations) do
  for name, animation in pairs(animations) do
    animation.type = "animation"
    animation.name = string.format(mod_prefix .. "%s-%s", corner, name)
    data:extend{animation}
  end
end
