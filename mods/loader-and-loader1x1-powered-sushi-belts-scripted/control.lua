-- for _, event in ipairs({
--   defines.events.on_built_entity,
--   defines.events.on_robot_built_entity,
--   defines.events.script_raised_built,
--   defines.events.script_raised_revive,
--   defines.events.on_entity_cloned,
-- }) do
--   script.on_event(event, on_created_entity, {
--     {filter = 'name', name = 'aai-signal-sender'},
--     {filter = 'name', name = 'aai-signal-receiver'},
--   })
-- end

local Sushi = {}

function Sushi.on_loader_marked(entity)
  if global.structs[entity.unit_number] then return true end

  if entity.loader_container == nil then return false, "Loader has no container." end
  if entity.loader_type ~= "output" then return false, "Loader oriented wrongly." end

  local multiplier = entity.type == "loader" and 1.0 or 0.5
  local x = entity.position.x
  local y = entity.position.y

  if entity.direction == defines.direction.north     then y = y + multiplier
  elseif entity.direction == defines.direction.east  then x = x - multiplier
  elseif entity.direction == defines.direction.south then y = y - multiplier
  elseif entity.direction == defines.direction.west  then x = x + multiplier
  else
    error(entity.direction)
  end

  local sushi_container = entity.surface.create_entity{
    name = "sushi-container-" .. entity.loader_container.prototype.get_inventory_size(defines.inventory.chest),
    force = entity.force,
    position = {x, y},
  }

  rendering.draw_sprite{
    sprite = "item/sushi-loader-marker",
    surface = sushi_container.surface,
    target = sushi_container,
    x_scale = 0.5,
    y_scale = 0.5,
    only_in_alt_mode = true,
  }

  global.structs[entity.unit_number] = {
    loader = entity,
    container = entity.loader_container,
    sushi_container = sushi_container,
  }

  -- refresh the loader to take from the sushi container since its position is closer than the previous container
  -- note that if a loader is sleeping on a container, updating the connections does not unlink the wakeup list.
  entity.update_connections()

  local at_tick = game.tick + 1
  if global.tasks[at_tick] then
    table.insert(global.tasks[at_tick], entity.unit_number)
  else
    global.tasks[at_tick] = {entity.unit_number}
  end

  -- game.print(serpent.line(entity.position) .. entity.direction)
end

script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item ~= "sushi-loader-marker" then return end

  local player = game.get_player(event.player_index)

  for _, entity in ipairs(event.entities) do
    local success, string = Sushi.on_loader_marked(entity)
    if success == false then
      player.create_local_flying_text{
        text = string,
        position = entity.position,
      }
    end
  end
end)

script.on_init(function(event)
  global.structs = {}

  global.tasks = {}
end)

function Sushi.spill(inventory)
  for name, count in pairs(inventory.get_contents()) do
    inventory.entity_owner.surface.spill_item_stack(
      inventory.entity_owner.position,
      {name = name, count = count},
      false, -- pickup 
      inventory.entity_owner.force,
      false -- belts
    )
  end
end

function Sushi.sum_inventory(inventory)
  local sum = 0
  for name, count in pairs(inventory.get_contents()) do
    sum = sum + count
  end
  return sum
end

function Sushi.get_unique_items(inventory)
  local unique_items = {}
  for name, count in pairs(inventory.get_contents()) do
    table.insert(unique_items, name)
  end
  return unique_items
end

function Sushi.smallest_count(inventory)
  local smallest = nil
  for name, count in pairs(inventory.get_contents()) do
    smallest = math.min(smallest or count, count)
  end
  return smallest
end

function Sushi.refill_from_container(struct)
  local inventory = struct.container.get_inventory(defines.inventory.chest)
  if inventory.is_empty() then return end
  
  local times = Sushi.smallest_count(inventory)
  local the_unique_items = Sushi.get_unique_items(inventory)

  local sushi_container = struct.sushi_container.get_inventory(defines.inventory.chest)
  times = math.min(times, math.floor(#sushi_container / #the_unique_items))

  -- game.print(serpent.block( inventory.get_contents() ))

  local slot = 1

  for i = 1, times do
    local unique_items = {table.unpack(the_unique_items)}

    while #unique_items > 0 do
      local index = math.random(1, #unique_items)
      local unique_item = unique_items[index]
      table.remove(unique_items, index)
  
      inventory.remove({name = unique_item, count = 1})
      sushi_container[slot].set_stack({name = unique_item, count = 1})
      slot = slot + 1
    end
  end
end

function Sushi.tick_struct(unit_number)
  local struct = global.structs[unit_number]
  if not struct then return end

  if not (struct.loader.valid and struct.container.valid and struct.sushi_container.valid) then
    if struct.sushi_container.valid then
      local inventory = struct.sushi_container.get_inventory(defines.inventory.chest)
      if not inventory.is_empty() then
        Sushi.spill(inventory) -- todo: perhaps insert into container if its still valid?
      end
      struct.sushi_container.destroy()
    end
    global.structs[unit_number] = nil
    return
  end

  local inventory = struct.sushi_container.get_inventory(defines.inventory.chest)
  -- inventory.insert({name="coin", count=1})

  -- log(serpent.line(inventory.is_empty()))
  if inventory.is_empty() then
    Sushi.refill_from_container(struct)
  end

  -- todo: calculate how fast the loader can empty tor chest

  -- game.player.selected.prototype.belt_speed * 480

  local sum_inventory = Sushi.sum_inventory(inventory)
  -- log(sum_inventory)
  local items_per_tick = struct.loader.prototype.belt_speed * 480 / 60 -- todo: cache

  -- at this tick the temorary inventory should be empty again right? why isn't it?
  -- it seems that almost a multiple of 2 is required, why is a problem for later :|
  local at_tick = game.tick + 1 + math.floor(sum_inventory * 2 * items_per_tick)
  if global.tasks[at_tick] then
    table.insert(global.tasks[at_tick], unit_number)
  else
    global.tasks[at_tick] = {unit_number}
  end
end

script.on_event(defines.events.on_tick, function(event)
  local tasks = global.tasks[event.tick]
  if tasks then global.tasks[event.tick] = nil
    for _, unit_number in ipairs(tasks) do
      Sushi.tick_struct(unit_number)
    end
  end
end)

-- commands.add_command("seed-infinity-chest", nil, function(command)
--   local player = game.get_player(command.player_index)
--   local selected = player.selected
  
--   if selected.name ~= 'infinity-chest' then return end

--   local items = {
--     'iron-plate',
--     'copper-plate',
--     'electronic-circuit',
--     'advanced-circuit',
--     'processing-unit',
--   }

--   for i, item in ipairs(items) do
--     selected.set_infinity_container_filter(i, {name = item, count = 50})
--   end
-- end)
