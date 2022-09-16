local util = require('util')
local labs = {}

--

function labs.init()
  global.proxy_to_entry_map = {}

  global.entries = {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ type = "lab" })) do
      labs.register(entity)
    end
  end

  global.lab_inputs = {}
  global.stack_size = {}
  for _, entity_prototype in pairs(game.entity_prototypes) do
    if entity_prototype.type == "lab" then
      global.lab_inputs[entity_prototype.name] = util.list_to_map(entity_prototype.lab_inputs)

      for _, lab_input in ipairs(entity_prototype.lab_inputs) do
        global.stack_size[lab_input] = game.item_prototypes[lab_input].stack_size
      end
    end
  end

  global.current_research_ingredients = {}
  for _, force in pairs(game.forces) do
    labs.on_research_changed({research = {force = force}})
  end
end

function labs.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.type ~= "lab" then return end

  labs.register(entity)
end

function labs.register(entity)
  global.entries[entity.unit_number] = {
    entity = entity,
    unit_number = entity.unit_number,
    proxy = nil,
  }
end

function labs.random_tick(entry)

  -- delete this entry if the lab ever turns invalid
  if not entry.entity or not entry.entity.valid then
    global.entries[entry.unit_number] = nil
    return false
  end

  local current_research_ingredients = global.current_research_ingredients[entry.entity.force.index]
  -- do not restock if the force is not researching anything
  if #current_research_ingredients == 0 then return true end

  -- skip this lab if it does not have slots for all the required science packs
  for _, current_research_ingredient in ipairs(current_research_ingredients) do
    if not global.lab_inputs[entry.entity.name][current_research_ingredient] then
      return true
    end
  end

  -- get any cards already in the lab
  local inventory = entry.entity.get_inventory(defines.inventory.lab_input)
  local contents = inventory.get_contents()

  local to_request = {}
  local to_request_empty = true
  for _, lab_input in ipairs(current_research_ingredients) do
    local missing = global.stack_size[lab_input] - (contents[lab_input] or 0)
    if missing > 0 then
      to_request[lab_input] = missing
      to_request_empty = false
    end
  end

  if not to_request_empty then
    if entry.proxy and entry.proxy.valid then
      entry.proxy.item_requests = to_request
      -- game.print('update proxy')
    else
      -- game.print('create proxy')
      entry.proxy = entry.entity.surface.create_entity({
        name = "item-request-proxy",
        position = entry.entity.position,
        target = entry.entity,
        force = entry.entity.force,
        modules = to_request
      })

      global.proxy_to_entry_map[script.register_on_entity_destroyed(entry.proxy)] = entry.unit_number
    end
  end

  return true
end

function labs.on_entity_destroyed(event)
  local unit_number = global.proxy_to_entry_map[event.registration_number]
  if not unit_number then return end

  -- labs.random_tick(global.entries[unit_number])
end

function labs.on_research_changed(event)
  local force = event.force or event.research.force

  global.current_research_ingredients[force.index] = {}

  if force.current_research then
    for _, research_unit_ingredient in ipairs(force.current_research.research_unit_ingredients) do
      table.insert(global.current_research_ingredients[force.index], research_unit_ingredient.name)
    end

    labs.every_minute()
  end
end

function labs.every_minute()
  for _, entry in pairs(global.entries) do
    labs.random_tick(entry)
  end
end

--

return labs
