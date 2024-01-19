script.on_init(function(event)
  global.clones = {}
end)

local within_tick = {}

-- before FilterHelper's on_gui_click
script.on_event(defines.events.on_gui_click, function(event)
  if event.element and event.element.tags and (event.element.tags.action == "fh_select_button" or event.element.tags.action == "fh_deselect_button") then
    local player = game.get_player(event.player_index)
    local opened = player.opened
    if opened then
      within_tick[player.index] = opened
      local coin = {name = "coin", count = 1}
      if player.get_main_inventory().insert(coin) then
        player.get_main_inventory().remove(coin)
      end
    end
  end
end)

function on_tick()
  for _, clone in ipairs(global.clones) do
    clone.destroy()
  end

  global.clones = {}
  script.on_event(defines.events.on_tick, nil)
end

-- always resets the filters, it does not check if there are gaps prior
function left_align_filters(entity)
  local filters = {}

  for i = 1, entity.filter_slot_count do
    local filter = entity.get_filter(i)
    if filter then
      table.insert(filters, filter)
    end
    entity.set_filter(i, nil)
  end

  for i, filter in ipairs(filters) do
    entity.set_filter(i, filter)
  end
end

-- after FilterHelper's on_gui_click
script.on_event(defines.events.on_player_main_inventory_changed, function(event)
  local player = game.get_player(event.player_index)
  local opened = within_tick[player.index]
  within_tick[player.index] = nil

  -- FilterHelper should have set it to nil
  if player.opened then return end

  if not opened then return end
  if not opened.valid then return end

  left_align_filters(opened)

  local position = opened.position
  if opened.type == "loader-1x1" or opened.type == "loader" then
    position = player.surface.find_non_colliding_position('beacon', player.position, player.reach_distance, 1, true)
    if position == nil then
      -- why a beacon? a 3x3 entity unlikely to be overriden by mods, so 1x1 loaders cannot touch belts and cause snapping
      error(string.format('no beacon could be placed within reach distance of %s.', player.name))
    end
  end

  local clone = opened.clone{
    position = position,
    surface = opened.surface,
    force = opened.force,
    create_build_effect_smoke = false,
  }

  if not clone then
    game.print('filter helper helper: cloning '.. opened.name ..' failed somehow.')
    return
  end

  clone.destructible = false
  clone.active = false
  player.opened = clone

  table.insert(global.clones, clone)
  script.on_event(defines.events.on_tick, on_tick)
end)

script.on_load(function(event)
  if #global.clones > 0 then
    script.on_event(defines.events.on_tick, on_tick)
  end
end)
