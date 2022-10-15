local bubble = {}

function bubble.init()
  global.deliveries = {}
  global.deliveries_table_was_previously_empty = true

  global.entries = {}
  rendering.clear('glutenfree-ltn-thought-bubble')
end

function bubble.on_dispatcher_updated(event)
  -- game.print('on_dispatcher_updated @ ' .. event.tick)
  global.deliveries = event.deliveries

  if global.deliveries_table_was_previously_empty then
    global.deliveries_table_was_previously_empty = false
    game.print('Glutenfree LTN thought bubbles activated')
    
    for _, delivery in pairs(global.deliveries) do
      if delivery.train.valid then
        bubble.update_train(delivery.train)
      end
    end
  end
end

function bubble.on_delivery_created(event)
  -- game.print('on_delivery_created @ ' .. event.tick)
  global.deliveries[event.train.id] = event

  bubble.update_train(event.train)
end

function bubble.on_train_schedule_changed(event)
  bubble.update_train(event.train)
end

function bubble.update_train(train)
  if not global.entries then return end -- LTN updating all trains prior to our init/load

  local delivery = global.deliveries[train.id]
  if not delivery or not bubble.train_is_approaching_station(train, delivery.from) then

    if global.entries[train.id] then
      for _, sprite_id in ipairs(global.entries[train.id].sprites) do
        rendering.destroy(sprite_id)
      end
      global.entries[train.id] = nil
    end

    return
  end

  if global.entries[train.id] then return end -- there's already a thought bubble active

  local entry = {
    train = train,
    sprites = {},
  }

  local what = bubble.pick_one_what_from_shipment(delivery.shipment)
  if not what then
    game.print(serpent.block(delivery))
    return
  end
  local shipment_sprite = what:gsub(',','.')

  for _, locomotive in ipairs(bubble.get_locomotives(train)) do
    entry.sprites[#entry.sprites+1] = rendering.draw_sprite{
      sprite = 'utility.entity_info_dark_background',
      target = locomotive,
      surface = locomotive.surface,
      target_offset = {0, -0.75}, -- data.raw['locomotive']['locomotive'].alert_icon_shift - 0.2
      x_scale = 0.75, -- looks good-ish
      y_scale = 0.75, -- looks good-ish
      only_in_alt_mode = true,
    }

    entry.sprites[#entry.sprites+1] = rendering.draw_sprite{
      sprite = shipment_sprite,
      target = locomotive,
      surface = locomotive.surface,
      target_offset = {0, -0.75}, -- data.raw['locomotive']['locomotive'].alert_icon_shift - 0.2
      x_scale = 0.80, -- looks good-ish
      y_scale = 0.80, -- looks good-ish
      only_in_alt_mode = true,
    }
  end

  global.entries[train.id] = entry
end

-- our code cannot handle multiple sprites, so pick 1
function bubble.pick_one_what_from_shipment(shipment)
  for what, count in pairs(shipment) do
    -- ^ == "item,se-iridium-blastcake"
    return what
  end

  return nil
end

-- unwrap front & back movers into one
function bubble.get_locomotives(train)
  local locomotives = {}

  for front_or_back, array in pairs(train.locomotives) do
    for _, locomotive in ipairs(array) do
      table.insert(locomotives, locomotive)
    end
  end

  return locomotives
end

function bubble.train_is_approaching_station(train, station_backer_name)
  -- can't approach without a schedule
  if not train.schedule then return false end

  -- require more than 2 stops (depot + temp + station)
  if #train.schedule.records < 3 then return false end

  -- is there still a (temporary) stop between the train and this station?
  for i = train.schedule.current + 1, #train.schedule.records do
    if train.schedule.records[i].station then
      if train.schedule.records[i].station == station_backer_name then
        return true
      end
    end
  end

  -- currently at this station, or already went past it
  return false
end

function bubble.gc()
  local valid_train_ids = {}

  for _, surface in pairs(game.surfaces) do
    for _, train in pairs(surface.get_trains()) do
      valid_train_ids[train.id] = true
    end
  end

  for train_id, entry in pairs(global.entries) do
    if not valid_train_ids[train_id] or not entry.train.valid then

      for _, sprite_id in ipairs(global.entries[train_id].sprites) do
        rendering.destroy(sprite_id)
      end

      global.entries[train_id] = nil

    end
  end
end

return bubble
