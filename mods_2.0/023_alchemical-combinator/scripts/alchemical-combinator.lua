local AlchemicalCombinator = {}

local mod_surface_name = "alchemical-combinator"

local function not_yet_seen(seen, key)
  if seen[key] then return false end
  seen[key] = true
  return true
end

function AlchemicalCombinator.reread(struct)
  assert(struct)

  struct.conditions = {}
  for _, condition in ipairs(struct.alchemical_combinator.get_control_behavior().parameters.conditions or {}) do
    -- filter out any player configured special signals (or accidentally copied everything from -active)
    if condition.first_signal and condition.first_signal.type == "virtual" then goto continue end
    table.insert(struct.conditions, {
      first_signal = condition.first_signal,
      second_signal = condition.second_signal,
    })
    ::continue::
  end

  local constant_cb = struct.constant.get_control_behavior()

  -- making a new one ensures all the old ones are overwritten in case the total index count is lower
  constant_cb.remove_section(1)
  local section = constant_cb.add_section()

  local seen = {}
  for i, condition in pairs(struct.conditions) do
    local first_signal = condition.first_signal
    if first_signal then
      local value = {type = first_signal.type or "item", name = first_signal.name, quality = first_signal.quality or "normal", comparator = '='}
      if not_yet_seen(seen, value.type .. value.name .. value.quality) then
        section.set_slot(i, {
          value = value,
          min = 1,
        })
      end
    end
  end

  local mod_surface = game.surfaces[mod_surface_name]
  local to_outside_green = struct.decider.get_wire_connector(defines.wire_connector_id.combinator_output_green, false)
  local to_outside_red   = struct.decider.get_wire_connector(defines.wire_connector_id.combinator_output_red  , false)
  local to_inside_red    = struct.decider.get_wire_connector(defines.wire_connector_id.combinator_input_red   , false)

  for i, condition in pairs(struct.conditions) do
    local arithmetic = struct.arithmetics[i]
    if arithmetic == nil then
      arithmetic = mod_surface.create_entity{
        name = "arithmetic-combinator",
        force = "neutral",
        position = {struct.id - 1, -4 + (-2 * i)},
        direction = defines.direction.south
      }
      assert(arithmetic)
      table.insert(struct.arithmetics, arithmetic)

      assert(arithmetic.get_wire_connector(defines.wire_connector_id.combinator_input_red, false).connect_to(to_inside_red, false))
      assert(arithmetic.get_wire_connector(defines.wire_connector_id.combinator_output_red, false).connect_to(to_outside_red, false))
      assert(arithmetic.get_wire_connector(defines.wire_connector_id.combinator_output_green, false).connect_to(to_outside_green, false))
    end

    arithmetic.get_control_behavior().parameters = {
      first_signal = condition.first_signal,
      first_signal_networks = {
        green = true,
        red = true
      },
      operation = "+",
      output_signal = condition.second_signal,
      second_signal_networks = {
        green = true,
        red = true
      }
    }
  end

  -- purge all the arithmetic combinators that were not used
  for i = #struct.arithmetics, #struct.conditions + 1, -1 do
    struct.arithmetics[i].destroy()
    struct.arithmetics[i] = nil
  end

  AlchemicalCombinator.write_parameters_back(struct)
end

function AlchemicalCombinator.write_parameters_back(struct)

  local conditions = {}

  for _, condition in ipairs(struct.conditions) do
    table.insert(conditions, {
      constant = nil, -- no way to force it not be 0 :(
      comparator = "=",
      compare_type = "and", -- probably better for performance?
      first_signal = condition.first_signal,
      first_signal_networks = {
        green = true,
        red = true
      },
      second_signal = condition.second_signal,
      second_signal_networks = {
        green = true,
        red = true
      }
    })
  end

  struct.alchemical_combinator.get_control_behavior().parameters = {conditions = conditions, outputs = {}}
end

return AlchemicalCombinator
