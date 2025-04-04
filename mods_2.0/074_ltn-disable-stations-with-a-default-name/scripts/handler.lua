local Handler = {}

function Handler.init()
  storage.backer_names = {}
  for _, name in pairs(game.backer_names) do
    storage.backer_names[name] = true
  end

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered{name = "logistic-train-stop"}) do
      Handler.on_entity_renamed({entity = entity})
    end
  end
end

local function is_default_logistic_condition(logistic_condition)
  return logistic_condition.comparator == "<" and logistic_condition.constant == 0
end

function Handler.on_entity_renamed(event)
  local entity = event.entity or event.destination
  if entity.name ~= "logistic-train-stop" then return end

  local cb = entity.get_or_create_control_behavior()
  if not is_default_logistic_condition(cb.logistic_condition) then return end

  if storage.backer_names[entity.backer_name] then
    cb.connect_to_logistic_network = true
    -- entity.custom_status = {
    --   diode = defines.entity_status_diode.red,
    --   label = {"entity-status.default-name-used"},
    -- }
  else
    cb.connect_to_logistic_network = false
    -- entity.custom_status = nil
  end
end

return Handler
