local ModSurface = {}

ModSurface.name = "alchemical-combinator"

function ModSurface.on_gui_closed(event)
  if event.entity and event.entity.name == "alchemical-combinator" then
    -- game.print(serpent.block( event.entity.get_control_behavior().parameters.conditions ))
    local struct_id = storage.alchemical_combinator_to_struct_id[event.entity.unit_number]
    local struct = storage.structs[struct_id]

    struct.conditions = {}
    for _, condition in ipairs(event.entity.get_control_behavior().parameters.conditions) do
      table.insert(struct.conditions, {
        first_signal = condition.first_signal,
        second_signal = condition.second_signal,
      })
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
        local seen_key = value.type .. value.name .. value.quality
        if seen[seen_key] == nil then
          seen[seen_key] = true
          section.set_slot(i, {
            value = value,
            min = 1,
          })
        end
      end
    end

    ModSurface.write_parameters_back(struct)
  end
end

function ModSurface.write_parameters_back(struct)

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

return ModSurface
