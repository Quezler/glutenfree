local Interface = {}

function Interface.refresh_effects(unit_number)
  local struct = assert(storage.structs[unit_number], unit_number)

  struct.inventory.clear()
  for effect, value in pairs(struct.effects) do
    if 0 > value then
      struct.inventory.insert({name = string.format(mod_prefix .. "%s-module-16", effect)})
    end
    local bits = get_bits(value)
    for i, bit in ipairs(bits) do
      if bit == 1 then
        local two_character_number = string.format("%02d", i)
        local module_name = string.format(mod_prefix .. "%s-module-%s", effect, two_character_number)
        assert(struct.inventory.insert({name = module_name}), module_name)
      end
    end
  end
end

function Interface.get_effects(unit_number)
  local struct = assert(storage.structs[unit_number], unit_number)

  return struct.effects
end

function Interface.get_effect(unit_number, effect)
  local struct = assert(storage.structs[unit_number], unit_number)

  return struct.effects[effect]
end

local function validate_effects(effects)
  for effect, _ in pairs(effects) do
    assert(shared.get_empty_effects()[effect] == 0, effect)
  end
  local validated = shared.get_empty_effects()
  for _, effect in pairs(shared.effects) do
    local strength = effects[effect]
    assert(type(strength) == "number", type(strength))
    assert(shared.max_strength >= strength, strength)
    assert(shared.min_strength <= strength, strength)
    validated[effect] = strength
  end
  return validated
end

function Interface.set_effects(unit_number, effects)
  local struct = assert(storage.structs[unit_number], unit_number)

  struct.effects = validate_effects(effects)
  Interface.refresh_effects(unit_number)
end

function Interface.set_effect(unit_number, effect, strength)
  local struct = assert(storage.structs[unit_number], unit_number)

  struct.effects[effect] = strength
  Interface.set_effects(unit_number, struct.effects) -- validation happens here
end

remote.add_interface("beacon-interface", Interface)
return Interface
