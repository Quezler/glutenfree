local Spaceship = require('__space-exploration-scripts__.spaceship')
local SpaceshipGUI = require('__space-exploration-scripts__.spaceship-gui')

--

local handler = {}

handler.on_init = function(event)
  global.engines = {}

  global.spaceship_console_outputs = {}
  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-spaceship-console-output'})) do
      local spaceship_id = entity.get_or_create_control_behavior().get_signal(1).count
      global.spaceship_console_outputs[spaceship_id] = entity
    end
  end
end

handler.on_entity_cloned = function(event)
  -- event.destination.products_finished = 0

  if event.destination.name == "se-spaceship-console-output" then
    local spaceship_id = event.destination.get_or_create_control_behavior().get_signal(1).count
    global.spaceship_console_outputs[spaceship_id] = event.destination
    return
  end -- elseif is_engine(event.destination.name)

  global.engines[event.destination.unit_number] = {
    entity = event.destination,
    products_finished = event.destination.products_finished, -- at the time of launch
  }
end

handler.on_tick = function(event)
  if event.tick % Spaceship.tick_interval_gui == 0 then
    for _, player in pairs(game.connected_players) do
      handler.gui_update(player, event.tick)
    end
  end
end

handler.gui_update = function(player, tick)
  local root = player.gui.left[SpaceshipGUI.name_spaceship_gui_root]
  if root and root.tags and root.tags.index then
    local spaceship_id = tonumber(root.tags.index)
    -- game.print(root.tags.index)
    
    local entity = global.spaceship_console_outputs[spaceship_id]
    if entity and entity.valid then -- se-spaceship-console-output

      local surface = entity.surface
      if handler.surface_is_spaceship(surface) then

        local engines = surface.find_entities_filtered{ -- todo: cache
          name = {'se-spaceship-rocket-engine', 'se-spaceship-ion-engine', 'se-spaceship-antimatter-engine'}
        }

        if root["flow_speed"] and root["flow_speed"]["panel_speed"] then
          local panel = root["flow_speed"]["panel_speed"]

          -- this doesn't show in the 1-4 ticks between opening the dropdown, but its too unnoticable for now
          if not panel['fuel_usage_label'] then
            panel.add{
              type = "label",
              name = "fuel_usage_label"
            }
          end

          local sum = handler.sum_fuel_usage_for_engines(engines)
          -- game.print(serpent.block( sum ))

          local caption = {}
          for fuel_name, fuel_amount in pairs(sum) do
            if fuel_amount > -1 then
              table.insert(caption, "[fluid=" .. fuel_name .. "] " .. fuel_amount)
            end
          end

          panel['fuel_usage_label'].caption = table.concat(caption, " ")
        end

      end
    end
  end
end

handler.surface_is_spaceship = function(surface)
  local _, _, num = string.find(surface.name, "^spaceship%-(%d+)$")
  return not not num
end

handler.engine_name_to_fuel_name = {
  ['se-spaceship-rocket-engine']     = 'se-liquid-rocket-fuel',
  ['se-spaceship-ion-engine']        = 'se-ion-stream',
  ['se-spaceship-antimatter-engine'] = 'se-antimatter-stream',
}

handler.liquid_used_per_fuel_craft = {
  ['se-liquid-rocket-fuel'] = 5, -- every 0.1s = 50/s
  ['se-ion-stream']         = 1, -- every 0.5s =  2/s
  ['se-antimatter-stream']  = 1, -- every 0.5s =  2/s
}

handler.sum_fuel_usage_for_engines = function(engines)
  -- local sum = 0

  -- for _, engine in ipairs(engines) do
  --   local struct = global.engines[engine.unit_number]
  --   if struct and struct.entity.valid then
  --     sum = sum + (engine.products_finished - struct.products_finished)
  --   end
  -- end

  -- return sum

  -- -1 means the engine type is missing, if the engine is present but unused math.max below will set it to 0
  local sum = {
    ['se-liquid-rocket-fuel'] = -1,
    ['se-ion-stream']         = -1,
    ['se-antimatter-stream']  = -1,
  }

  for _, engine in ipairs(engines) do
    local struct = global.engines[engine.unit_number]
    if struct and struct.entity.valid then
      local fuel_name = handler.engine_name_to_fuel_name[engine.name]
      sum[fuel_name] = math.max(0, sum[fuel_name]) + (engine.products_finished - struct.products_finished)
    end
  end

  return sum
end

handler.gc = function()
  -- garbage created when a spaceship gets decomissioned
  for spaceship_id, entity in pairs(global.spaceship_console_outputs) do
    if not entity.valid then global.spaceship_console_outputs[spaceship_id] = nil end
  end

  -- garbage generally left behind a spaceship launching
  for unit_number, entity in pairs(global.engines) do
    if not entity.valid then global.engines[unit_number] = nil end
  end
end

--

script.on_init(handler.on_init)

script.on_event(defines.events.on_tick, handler.on_tick)

script.on_event(defines.events.on_entity_cloned, handler.on_entity_cloned, {
  {filter = 'name', name = 'se-spaceship-console-output'},

  {filter = 'name', name = 'se-spaceship-rocket-engine'},
  {filter = 'name', name = 'se-spaceship-ion-engine'},
  {filter = 'name', name = 'se-spaceship-antimatter-engine'},
})
