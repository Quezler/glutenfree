local Zone = require('__space-exploration-scripts__.zone')
local Util = require('__space-exploration__.scripts.util')
local Spaceship = require('__space-exploration-scripts__.spaceship')
local Launchpad = {name_rocket_launch_pad = 'se-rocket-launch-pad'}
local LaunchpadGUI = {name_rocket_launch_pad_gui_root = 'se-rocket-launch-pad-gui'}

local function on_created_entity(event)
  local entity = event.created_entity or event.entity

  local tank_position = {entity.position.x, entity.position.y + 1}
  local ion_tank_position = {entity.position.x, entity.position.y + 2}
  local ion_tank = entity.surface.find_entity('se-rocket-launch-pad-tank-ion', ion_tank_position)
  if ion_tank == nil then
    ion_tank = entity.surface.create_entity{
      name = 'se-rocket-launch-pad-tank-ion',
      force = entity.force,
      position = ion_tank_position,
    }
    ion_tank.destructible = false
    entity.connect_neighbour({wire = defines.wire_type.red, target_entity = ion_tank})
    entity.connect_neighbour({wire = defines.wire_type.green, target_entity = ion_tank})
  end

  global.deathrattles[script.register_on_entity_destroyed(entity)] = entity.unit_number

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    
    container = entity,
    tank = entity.surface.find_entity('se-rocket-launch-pad-tank', tank_position),
    ion_tank = ion_tank,

    recently_received_ion = false,
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-rocket-launch-pad'},
  })
end

local function on_configuration_changed(event)
  -- 4'000'000 / 2'000'000 = 2.0 -- 2x rocket fuel
  global.ion_exchange_rate = Spaceship.ion_stream_energy / game.fluid_prototypes['se-liquid-rocket-fuel'].fuel_value
  global.surface_is_space = {}
end

script.on_init(function(event)
  global.structs = {}
  global.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-rocket-launch-pad'})) do
      on_created_entity({entity = entity})
    end
  end

  on_configuration_changed(event)
end)

script.on_configuration_changed(on_configuration_changed)

local function get_surface_is_space(surface)
  -- if 'debug' then return true end
  if global.surface_is_space[surface.index] == nil then
    local zone = Zone.from_surface_index(surface.index)

    global.surface_is_space[surface.index] = zone and Zone.is_space(zone) or false
  end

  return global.surface_is_space[surface.index]
end

local function tick_struct(struct)
  local fluids = struct.ion_tank.get_fluid_contents()

  if fluids['se-liquid-rocket-fuel'] then
    struct.recently_received_ion = false
    local transferred = struct.tank.insert_fluid({name = 'se-liquid-rocket-fuel', amount = fluids['se-liquid-rocket-fuel']})
    if transferred > 0 then
      struct.ion_tank.remove_fluid{
        name = 'se-liquid-rocket-fuel',
        amount = transferred,
      }
    end
  end

  if fluids['se-ion-stream'] and get_surface_is_space(struct.container.surface) then
    struct.recently_received_ion = true
    local transferred = struct.tank.insert_fluid({name = 'se-liquid-rocket-fuel', amount = fluids['se-ion-stream'] * global.ion_exchange_rate})
    if transferred > 0 then
      struct.ion_tank.remove_fluid{
        name = 'se-ion-stream',
        amount = transferred / global.ion_exchange_rate,
      }
    end
  end

end

local function tick_player(player)
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local fuel_capacity_progress = root.children[2].children[1]['fuel_capacity_progress']

  local struct = global.structs[root.tags.unit_number]
  if struct == nil then return end -- nil when the silo is freshly placed somehow (possibly my cargo rocket label mod?)

  if struct.recently_received_ion == false then
    fuel_capacity_progress.style = 'se_launchpad_progressbar_fuel'
    return
  end

  fuel_capacity_progress.style = 'se_launchpad_progressbar_ion'

  local caption = fuel_capacity_progress.caption
  caption[1] = 'space-exploration.label_liquid_ion_stream'

  local fuel_k_min_string = caption[2][2]
  local fuel_k_min = tonumber(fuel_k_min_string:sub(1, -2))  -- remove the k, then cast to number
  caption[2][2] = Util.format_fuel(fuel_k_min / global.ion_exchange_rate * 1000)

  local fuel_k_max_string = caption[2][3]
  if fuel_k_max_string ~= '?' then
    local fuel_k_max = tonumber(fuel_k_max_string:sub(1, -2)) -- remove the k, then cast to number
    caption[2][3] = Util.format_fuel(fuel_k_max / global.ion_exchange_rate * 1000)
  end

  fuel_capacity_progress.caption = caption
end

script.on_event(defines.events.on_tick, function(event)
  for _, struct in pairs(global.structs) do
    if (event.tick + struct.unit_number + 1) % 60 == 0 then -- 1 tick before SE ticks the silo
      tick_struct(struct)
    end
  end

  if event.tick % 60 == 0 then
    for _, player in pairs(game.connected_players) do
      tick_player(player)
    end
  end
end)

script.on_event(defines.events.on_gui_opened, function(event)
  if event.entity and event.entity.name == Launchpad.name_rocket_launch_pad then
    tick_player(game.get_player(event.player_index))
  end
end)

script.on_event(defines.events.on_gui_selection_state_changed, function(event)
  if not (event.element and event.element.valid) then return end
  tick_player(game.get_player(event.player_index))
  -- local element = event.element
  -- local player = game.get_player(event.player_index)
  -- local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  -- if not (root and root.tags and root.tags.unit_number) then return end

  -- tick_player(player)
end)

-- surface indexes can be reused, which means another zone type might take its place
script.on_event(defines.events.on_surface_deleted, function(event)
  global.surface_is_space[event.surface_index] = nil
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    local struct = global.structs[deathrattle]
    if struct then global.structs[deathrattle] = nil
      struct.ion_tank.destroy()
    end
  end
end)
