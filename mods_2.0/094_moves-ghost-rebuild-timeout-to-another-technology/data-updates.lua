local function cut_effect(type, technology)
  for i, effect in ipairs(technology.effects) do
    if effect.type == type then
      table.remove(technology.effects, i)
      return effect
    end
  end

  error(string.format('Technology "%s" does not have an effect of type "%s".', technology.name, type))
end

local ghost_rebuild = cut_effect("create-ghost-on-entity-death", data.raw["technology"]["construction-robotics"])
local to_technology = data.raw["technology"][settings.startup["move-ghost-rebuild-timeout-to"].value]
if to_technology == nil then to_technology = data.raw["technology"]["military"] end
if to_technology == nil then error('Fallback technology "military" not found.') end

table.insert(to_technology.effects, 1, ghost_rebuild)
