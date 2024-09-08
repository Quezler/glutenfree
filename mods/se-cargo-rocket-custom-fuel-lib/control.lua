local Util = require('__space-exploration__.scripts.util')
local Zone = require('__space-exploration-scripts__.zone')
local Launchpad = {name_rocket_launch_pad = 'se-rocket-launch-pad'}
local LaunchpadGUI = {name_rocket_launch_pad_gui_root = 'se-rocket-launch-pad-gui'}

local function on_created_entity(event)
  local entity = event.created_entity or event.entity

  local tank_position = {entity.position.x, entity.position.y + 1}
  local mixed_tank_position = {entity.position.x, entity.position.y + 2}
  local mixed_tank = entity.surface.find_entity('se-rocket-launch-pad-tank-mixed', mixed_tank_position)
  if mixed_tank == nil then
    mixed_tank = entity.surface.create_entity{
      name = 'se-rocket-launch-pad-tank-mixed',
      force = entity.force,
      position = mixed_tank_position,
    }
    mixed_tank.destructible = false
    entity.connect_neighbour({wire = defines.wire_type.red, target_entity = mixed_tank})
    entity.connect_neighbour({wire = defines.wire_type.green, target_entity = mixed_tank})
  end

  global.deathrattles[script.register_on_entity_destroyed(entity)] = entity.unit_number

  global.structs[entity.unit_number] = {
    unit_number = entity.unit_number,

    container = entity,
    tank = entity.surface.find_entity('se-rocket-launch-pad-tank', tank_position),
    mixed_tank = mixed_tank,

    last_fuel = 'se-liquid-rocket-fuel',
  }
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
}) do
  script.on_event(event, on_created_entity, {
    {filter = 'name', name = 'se-rocket-launch-pad'},
  })
end

local function on_init()
  global.fuels = {
    ['se-liquid-rocket-fuel'] = {color = {r=242/255, g=106/255, b=15/255}},
  }
  global.structs = {}
  global.deathrattles = {}
  global.surface_is_space = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = 'se-rocket-launch-pad'})) do
      on_created_entity({entity = entity})
    end
  end
end

local function on_configuration_changed()
  global.fuels = {
    ['se-liquid-rocket-fuel'] = {color = {r=242/255, g=106/255, b=15/255}},
  }
  global.surface_is_space = {}
end

script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)

local function add_fuel(data)
  assert(data.name)
  assert(data.name ~= 'se-liquid-rocket-fuel')
  assert(game.fluid_prototypes[data.name])

  if data.fuel_value == nil then
    data.fuel_value = game.fluid_prototypes[data.name].fuel_value
    assert(data.fuel_value > 0)
  end

  -- anything except nil or false is true
  if data.require_space == false then
    data.require_space = nil
  end

  if data.base_color == nil then
    data.base_color = game.fluid_prototypes[data.name].base_color
  end

  global.fuels[data.name] = {
    name = data.name,
    base_color = data.base_color,
    fuel_value = data.fuel_value,
    exchange_rate = data.fuel_value / game.fluid_prototypes['se-liquid-rocket-fuel'].fuel_value, -- internal mod value
    require_space = data.require_space ~= nil,
  }
end

remote.add_interface('se-cargo-rocket-custom-fuel-lib', {
  add_fuel = add_fuel,
})

local function get_surface_is_space(surface)
  -- if 'debug' then return true end
  if global.surface_is_space[surface.index] == nil then
    local zone = Zone.from_surface_index(surface.index)
    assert(zone)

    global.surface_is_space[surface.index] = zone and Zone.is_space(zone) or false
  end

  return global.surface_is_space[surface.index]
end

script.on_event(defines.events.on_surface_deleted, function(event)
  global.surface_is_space[event.surface_index] = nil
end)

local function tick_struct(struct)
  local fluids = struct.mixed_tank.get_fluid_contents()

  for fluid_name, fluid_amount in pairs(fluids) do
    if fluid_name == 'se-liquid-rocket-fuel' then
      struct.last_fuel = fluid_name
      local transferred = struct.tank.insert_fluid({name = 'se-liquid-rocket-fuel', amount = fluid_amount})
      if transferred > 0 then
        struct.mixed_tank.remove_fluid{
          name = fluid_name,
          amount = transferred,
        }
      end
    else
      local fluid_data = global.fuels[fluid_name]
      if fluid_data then
        struct.last_fuel = fluid_name

        if fluid_data.require_space and get_surface_is_space(struct.container.surface) == false then return end

        local transferred = struct.tank.insert_fluid({name = 'se-liquid-rocket-fuel', amount = fluid_amount * fluid_data.exchange_rate})
        if transferred > 0 then
          struct.mixed_tank.remove_fluid{
            name = 'se-ion-stream',
            amount = transferred / fluid_data.exchange_rate,
          }
        end
      end
    end
  end

end

local function tick_player(player)
  local root = player.gui.relative[LaunchpadGUI.name_rocket_launch_pad_gui_root]
  if not (root and root.tags and root.tags.unit_number) then return end

  local fuel_capacity_progress = root.children[2].children[1]['fuel_capacity_progress']

  local struct = global.structs[root.tags.unit_number]
  if struct == nil then return end -- nil when the silo is freshly placed somehow (possibly my cargo rocket label mod?)

  local fuel_data = global.fuels[struct.last_fuel]
  if fuel_data == nil or struct.last_fuel == 'se-liquid-rocket-fuel' then
    fuel_capacity_progress.style.color = global.fuels['se-liquid-rocket-fuel'].color
    return
  end

  fuel_capacity_progress.style.color = fuel_data.base_color

  local caption = fuel_capacity_progress.caption
  -- log(serpent.block(caption))
  caption[1] = 'se-cargo-rocket-fuel-lib.fuel_label'
  caption[3] = caption[2]
  caption[2] = {'fluid-name.' .. fuel_data.name}
  -- log(serpent.block(caption))

  local fuel_k_min_string = caption[3][2]
  if fuel_k_min_string == nil then
    -- {
    --   "se-cargo-rocket-fuel-lib.fuel_label",
    --   {
    --     "fluid-name.se-ion-stream"
    --   },
    --   {
      --   "fluid-name.se-ion-stream"
      -- }
    -- }
    -- vs
    -- {
    --   "se-cargo-rocket-fuel-lib.fuel_label",
    --   {
    --     "fluid-name.se-ion-stream"
    --   },
    --   {
    --     "space-exploration.simple-a-b-divide",
    --     "2.60k",
    --     "2.60k"
    --   }
    -- }
    return -- this happens when you change the launch trigger, never looks empty to the human eye tho, weird.
  end

  local fuel_k_min = tonumber(fuel_k_min_string:sub(1, -2))  -- remove the k, then cast to number
  caption[3][2] = Util.format_fuel(fuel_k_min / fuel_data.exchange_rate * 1000)

  local fuel_k_max_string = caption[3][3]
  if fuel_k_max_string ~= '?' then
    local fuel_k_max = tonumber(fuel_k_max_string:sub(1, -2)) -- remove the k, then cast to number
    caption[3][3] = Util.format_fuel(fuel_k_max / fuel_data.exchange_rate * 1000)
  end

  fuel_capacity_progress.caption = caption
end

script.on_event(defines.events.on_tick, function(event)
  for _, struct in pairs(global.structs) do
    if (event.tick + struct.unit_number + 1) % 60 == 0 then -- 1 tick before SE ticks the silo
      tick_struct(struct)
    end
  end

  if event.tick % 60 == 0 then -- in the same tick but right after SE ticks the players
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
end)

script.on_event(defines.events.on_entity_destroyed, function(event)
  local deathrattle = global.deathrattles[event.registration_number]
  if deathrattle then global.deathrattles[event.registration_number] = nil
    local struct = global.structs[deathrattle]
    if struct then global.structs[deathrattle] = nil
      struct.mixed_tank.destroy()
    end
  end
end)
