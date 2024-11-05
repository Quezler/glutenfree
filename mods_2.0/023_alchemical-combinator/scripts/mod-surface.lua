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
