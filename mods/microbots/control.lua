script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  local inventory = game.create_inventory(1)

  local entity = event.entity
  local surface = entity.surface
  local position = entity.position

  while true do
    if entity.valid == false then break end -- we don't need to check for success :3
    local success = entity.mine{inventory = inventory}

    for slot = 1, #inventory do
      -- log(slot)
      local itemstack = inventory[slot]
      local dropped_items = surface.spill_item_stack(
        --[[position = --]] position,
        --[[items = --]] itemstack,
        --[[enable_looted = --]] false,
        --[[force = --]] nil,
        --[[allow_belts = --]] false
      )
      for _, dropped_item in ipairs(dropped_items or {}) do
        -- log(_)
        table.insert(global.dropped_items, {
          entity = dropped_item,
          target = game.get_player(1).character,
        })
      end
    end

    inventory.clear()
  end

  inventory.destroy()
end)

script.on_init(function(event)
  global.dropped_items = {}
end)

local function slightly_closer(a, b)
  local direction = {x = b.x - a.x, y = b.y - a.y}
  local magnitude = math.sqrt(direction.x^2 + direction.y^2)

  direction.x = direction.x / magnitude
  direction.y = direction.y / magnitude

  local newPosX = a.x + 0.1 * direction.x
  local newPosY = a.y + 0.1 * direction.y

  return {x = newPosX, y = newPosY}
end

function distance_between(a, b)
  local dx = b.x - a.x
  local dy = b.y - a.y

  local distance = math.sqrt(dx^2 + dy^2)
  return distance
end

script.on_event(defines.events.on_tick, function(event)
  -- log(#global.dropped_items)
  for i = #global.dropped_items, 1, -1 do
    local dropped_item = global.dropped_items[i]

    if dropped_item.entity.valid then
      dropped_item.entity.teleport(slightly_closer(dropped_item.entity.position, dropped_item.target.position))
    end
  end
end)

local function on_character_swapped(event)
  for _, dropped_item in pairs(global.dropped_items) do
    if dropped_item.target == event.old_character then
      dropped_item.target = event.new_character
    end
  end
end

remote.add_interface("microbots", {
  on_character_swapped = on_character_swapped,
})
