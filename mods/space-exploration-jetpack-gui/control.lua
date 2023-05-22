local Lifesupport = require('__space-exploration-scripts__.lifesupport')
local Jetpack = require('__space-exploration-scripts__.jetpack')

local JetpackGUI = {}

function JetpackGUI.on_configuration_changed(event)
  local fluid = game.fluid_prototypes['se-liquid-rocket-fuel']
  global.base_color = fluid.base_color
  global.flow_color = fluid.flow_color

  -- actually, the base color looks like shit, and its confusing while spacewalking, lets just use flow for both
  global.base_color = fluid.flow_color

  global.compatible_fuels = remote.call("jetpack", "get_fuels")
  -- {
  --   ["advanced-fuel"] = {
  --     thrust = 1.1000000000000001
  --   },
  --   ["bio-fuel"] = {
  --     thrust = 0.9
  --   },
  --   fuel = {
  --     thrust = 1
  --   },
  --   ["nuclear-fuel"] = {
  --     thrust = 1.1000000000000001
  --   },
  --   ["processed-fuel"] = {
  --     thrust = 1
  --   },
  --   ["rocket-booster"] = {
  --     thrust = 1.1000000000000001
  --   },
  --   ["rocket-fuel"] = {
  --     thrust = 1.2
  --   },
  --   ["solid-fuel"] = {
  --     thrust = 0.5
  --   }
  -- }

  -- cache their energy values instead of calling it each time akin to get_fuel_from_inventory
  for fuel_name, compatible_fuel in pairs(global.compatible_fuels) do
    if game.item_prototypes[fuel_name] then
      global.compatible_fuels[fuel_name].energy = game.item_prototypes[fuel_name].fuel_value
    else
      compatible_fuel[fuel_name] = nil -- item prototype does not exist for this combination of mods (e.g. petrochem's rocket booster)
    end
  end
end

function JetpackGUI.on_nth_tick(event)
  local tick_interval = Lifesupport.nth_tick_interval
  for _, player in pairs(game.connected_players) do
    -- every 240 ticks (every 4 seconds) per player (jetpack native)
    -- but since it looks better to update every second: added `% 1`
    if (event.tick/60 + player.index) % tick_interval % 1 == 0 then
      -- print(event.tick)
      -- game.print('hello dawling')
      JetpackGUI.on_lifesupport_gui_refreshed({player = player})
    end
  end
end

function JetpackGUI.on_lifesupport_gui_refreshed(event)
  local player = event.player or game.get_player(event.player_index)

  JetpackGUI.gui_update(player) -- we do not care about the expanded gui, we'll just let that be lifesupport
end

function JetpackGUI.gui_update(player)
  local root = Lifesupport.get_gui(player)
  if not root then return end -- also if already destroyed by the data not nil check within life support itself

  local is_jetpacking = remote.call("jetpack", "is_jetpacking", {character = player.character})

  
  -- root.panel.lifesupport_bar.caption = "senpai"

  root.panel.lifesupport_bar.style.color = is_jetpacking and global.flow_color or global.base_color

  if not player.character then return end
  local current_fuel = remote.call("jetpack", "get_current_fuels")[player.character.unit_number]
  -- {
  --   energy = <MJ left as a number>,
  --   name = "rocket-fuel",
  --   thrust = 1.2
  -- }
  if current_fuel then
    root.panel.lifesupport_bar.value = math.max(0, current_fuel.energy / global.compatible_fuels[current_fuel.name].energy)
    -- root.panel.lifesupport_bar.caption = {"[item=".. current_fuel.name .."]", {"item-name." .. current_fuel.name}}
    -- root.panel.lifesupport_bar.caption = "[item=".. current_fuel.name .."]"

    local fuel_consumption_rate = settings.global["jetpack-fuel-consumption"].value / 100
    local fuel_consumption_per_tick = Jetpack.fuel_use_base * fuel_consumption_rate
    local ing = "Hovering"

    if player.character.walking_state.walking then -- todo: check if `is_jetpacking` is true while spacewalking or not
      fuel_consumption_per_tick = fuel_consumption_per_tick + Jetpack.fuel_use_thrust * fuel_consumption_rate
      ing = "Thrusting"
    end

    root.panel["lifesupport_bar"].caption = Lifesupport.seconds_to_clock(current_fuel.energy / fuel_consumption_per_tick / 60)
    -- print('a ' .. current_fuel.energy)
    -- print('b ' .. JetpackGUI.sum_fuel_energy_from_inventory(player.character))
    root.panel["time_reserves_flow"]["lifesupport_reserves"].caption = Lifesupport.seconds_to_clock((current_fuel.energy + JetpackGUI.sum_fuel_energy_from_inventory(player.character)) / fuel_consumption_per_tick / 60)
    -- root.panel.lifesupport_bar.caption = fuel_consumption_per_tick

    -- replace character item with jetpack icon
    root.panel["time_reserves_flow"].children[1].sprite = "item/" .. "jetpack-1"

    -- replace life support canister with current fuel item
    root.panel["canister_reserves_flow"].children[1].sprite = "item/" .. current_fuel.name

    -- local inventory = player.character.get_inventory(defines.inventory.character_main).get_contents()

    root.panel.canister_reserves_flow.lifesupport_canisters.caption = player.character.get_main_inventory().get_item_count(current_fuel.name)
    root.panel.canister_reserves_flow.lifesupport_efficiency.caption = string.format("×%.f%%", current_fuel.thrust * 100)
    -- root.panel.canister_reserves_flow.lifesupport_efficiency.tooltip = nil

    print(serpent.block(root.panel.time_reserves_flow.info.tooltip))
    local x = (Jetpack.fuel_use_base + Jetpack.fuel_use_thrust) / Jetpack.fuel_use_base
    root.panel.time_reserves_flow.info.tooltip = "Flying takes "..x.."x more fuel than hovering"

    print('current: ' .. current_fuel.energy)
    print('prototy: ' .. global.compatible_fuels[current_fuel.name].energy)
    print('valuezy: ' .. math.max(0, current_fuel.energy / global.compatible_fuels[current_fuel.name].energy))
  end
end

function JetpackGUI.sum_fuel_energy_from_inventory(character)
  local energy = 0

  local inventory = character.get_main_inventory()
  if inventory and inventory.valid then
    for fuel_name, fuel_stats in pairs(global.compatible_fuels) do
      if game.item_prototypes[fuel_name] then
        local count = inventory.get_item_count(fuel_name)
        if count > 0 then
          energy = energy + fuel_stats.energy * count
        end
      end
    end
  end

  return energy
end

script.on_configuration_changed(JetpackGUI.on_configuration_changed)
script.on_nth_tick(Lifesupport.nth_tick_interval, JetpackGUI.on_nth_tick)

-- events that (can) call Lifesupport.gui_update (and thus cause the gui to refresh/reset prematurely)
script.on_event(defines.events.on_player_placed_equipment,        JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_removed_equipment,       JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_armor_inventory_changed, JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_changed_surface,         JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_driving_changed_state,   JetpackGUI.on_lifesupport_gui_refreshed)
