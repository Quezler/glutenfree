require("util")
local labs = {}

--

function labs.init()
  storage.proxy_to_entry_map = {}

  for unit_number, entry in pairs(storage.entries or {}) do
    if entry.proxy then
      entry.proxy.destroy()
    end
  end

  storage.entries = {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({ type = "lab" })) do
      labs.register(entity)
    end
  end

  storage.lab_inputs = {}
  storage.stack_size = {}

  storage.stack_for = {}
  for _, entity_prototype in pairs(prototypes.entity) do
    if entity_prototype.type == "lab" then
      storage.lab_inputs[entity_prototype.name] = util.list_to_map(entity_prototype.lab_inputs)
      storage.stack_for[entity_prototype.name] = {}

      for i, lab_input in ipairs(entity_prototype.lab_inputs) do
        storage.stack_for[entity_prototype.name][lab_input] = i - 1
        storage.stack_size[lab_input] = math.min(settings.startup["lab-resupply-amount"].value + 0, prototypes.item[lab_input].stack_size)
      end
    end
  end

  storage.current_research_ingredients = {}
  for _, force in pairs(game.forces) do
    labs.on_research_changed({force = force})
  end

  labs.every_minute()
end

function labs.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.type ~= "lab" then return end

  labs.register(entity)
  labs.random_tick(storage.entries[entity.unit_number])
end

function labs.register(entity)
  storage.entries[entity.unit_number] = {
    entity = entity,
    unit_number = entity.unit_number,
    proxy = nil,
  }
end

function labs.random_tick(entry)

  -- delete this entry if the lab ever turns invalid
  if not entry.entity or not entry.entity.valid then
    storage.entries[entry.unit_number] = nil
    return false
  end

  local current_research_ingredients = storage.current_research_ingredients[entry.entity.force.index]
  if not current_research_ingredients then
    error("force index: " .. entry.entity.force.index .. ", force name: " .. entry.entity.force.name .. ", size: " .. table_size(storage.current_research_ingredients))
  end

  -- do not restock if the force is not researching anything
  if #current_research_ingredients == 0 then return true end

  -- skip this lab if it does not have slots for all the required science packs
  for _, current_research_ingredient in ipairs(current_research_ingredients) do
    if not storage.lab_inputs[entry.entity.name][current_research_ingredient] then
      return true
    end
  end

  -- get any cards already in the lab
  local inventory = entry.entity.get_inventory(defines.inventory.lab_input)
  local contents = {}
  for _, item in ipairs(inventory.get_contents()) do
    contents[item.name] = (contents[item.name] or 0) + item.count -- group all the qualities together
  end

  local to_request = {}
  local to_request_empty = true
  for _, lab_input in ipairs(current_research_ingredients) do
    local missing = storage.stack_size[lab_input] - (contents[lab_input] or 0)
    if missing > 0 then
      to_request[lab_input] = missing
      to_request_empty = false
    end
  end

  if not to_request_empty then
    local bips = {}
    for item_name, item_count in pairs(to_request) do
      table.insert(bips, {
        id = {name = item_name, quality = "normal"},
        items = {in_inventory = {
          {
            inventory = defines.inventory.lab_input,
            stack = storage.stack_for[entry.entity.name][item_name],
            count = item_count,
          }
        }}
      })
    end

    if entry.proxy and entry.proxy.valid then
      entry.proxy.insert_plan = bips
      -- game.print("update proxy")
    else
      -- game.print("create proxy")
      entry.proxy = entry.entity.surface.create_entity({
        name = "item-request-proxy",
        position = entry.entity.position,
        target = entry.entity,
        force = entry.entity.force,
        modules = bips
      })

      storage.proxy_to_entry_map[script.register_on_object_destroyed(entry.proxy)] = entry.unit_number
    end
  end

  return true
end

function labs.on_object_destroyed(event)
  local unit_number = storage.proxy_to_entry_map[event.registration_number]
  if unit_number then storage.proxy_to_entry_map[event.registration_number] = nil
    labs.random_tick(storage.entries[unit_number])
  end
end

function labs.on_research_changed(event)
  local force = event.force or event.research.force

  storage.current_research_ingredients[force.index] = {}

  if force.current_research then
    for _, research_unit_ingredient in ipairs(force.current_research.research_unit_ingredients) do
      table.insert(storage.current_research_ingredients[force.index], research_unit_ingredient.name)
    end
  end

  -- in on_init we call this after updating the on_research_changed for every force,
  -- the real event will also contain research so we'll trigger it in here for those cases.
  if event.research then
    labs.every_minute()
  end
end

function labs.every_minute()
  for _, entry in pairs(storage.entries) do
    labs.random_tick(entry)
  end
end

--

return labs
