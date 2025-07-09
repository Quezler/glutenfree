local Lifesupport = require("__space-exploration-scripts__.lifesupport")
local Jetpack = require("__space-exploration-scripts__.jetpack")

local JetpackGUI = {}

function JetpackGUI.on_init(event)
  JetpackGUI.on_configuration_changed({})
end

function JetpackGUI.on_configuration_changed(event)
  local fluid = prototypes.fluid["se-liquid-rocket-fuel"]
  storage.flow_color = fluid.flow_color

  local compatible_fuels = remote.call("jetpack", "get_fuels")
  storage.compatible_fuels = {}
  if not compatible_fuels then return end -- why?

  if compatible_fuels["solid-fuel"] then
    storage.compatible_fuels = compatible_fuels
  else
    for _, compatible_fuel in pairs(compatible_fuels) do
      storage.compatible_fuels[compatible_fuel.fuel_name] = {thrust = compatible_fuel.thrust}
    end
  end

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
  for fuel_name, compatible_fuel in pairs(storage.compatible_fuels) do
    if prototypes.item[fuel_name] then
      storage.compatible_fuels[fuel_name].energy = prototypes.item[fuel_name].fuel_value
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
    if (event.tick / 60 + player.index) % tick_interval % 1 == 0 then
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

  if not player.character then return end
  local current_fuel = remote.call("jetpack", "get_current_fuel_for_character", {character=player.character})
  -- {
  --   energy = <MJ left as a number>,
  --   name = "rocket-fuel",
  --   thrust = 1.2
  -- }
  if current_fuel then

    -- change the life support blue to a fuel-ish color
    root.panel.lifesupport_bar.style.color = storage.flow_color

    -- the bar showing how much of the current fuel is still left
    if not storage.compatible_fuels then error("storage.compatible_fuels is nil.") end
    root.panel["lifesupport_bar"].value = math.max(0, current_fuel.energy / storage.compatible_fuels[current_fuel.name].energy)

    local fuel_consumption_rate = settings.global["jetpack-fuel-consumption"].value / 100
    local fuel_consumption_per_tick = Jetpack.fuel_use_base * fuel_consumption_rate

    local is_jetpacking = remote.call("jetpack", "is_jetpacking", {character = player.character})
    local is_spacewalking = player.character.name == "character" -- usage: `is_jetpacking and is_spacewalking`, actual jetpack mode is `character-jetpack`
    if is_jetpacking and player.character.walking_state.walking and not is_spacewalking then
      fuel_consumption_per_tick = fuel_consumption_per_tick + Jetpack.fuel_use_thrust * fuel_consumption_rate
    end

    -- i wonder if we"ll ever run into integer overflow issues if there's an absurd amount of fuel stored in the inventory
    root.panel["lifesupport_bar"].caption = Lifesupport.seconds_to_clock(math.max(0, current_fuel.energy / fuel_consumption_per_tick / 60))
    root.panel["lifesupport_bar"].tooltip = {"space-exploration.jetpack_suit_tooltip"}
    root.panel["time_reserves_flow"]["lifesupport_reserves"].caption = Lifesupport.seconds_to_clock(math.max(0, (current_fuel.energy + JetpackGUI.sum_fuel_energy_from_inventory(player.character)) / fuel_consumption_per_tick / 60))
    root.panel["time_reserves_flow"]["lifesupport_reserves"].tooltip = {"space-exploration.jetpack_reserves_duration_tooltip"}

    -- replace character icon with jetpack icon
    root.panel["time_reserves_flow"].children[1].sprite = "item/" .. "jetpack-1"
    root.panel["time_reserves_flow"].children[1].tooltip = {"space-exploration.jetpack_reserves_duration_tooltip"}

    -- replace life support canister with current fuel item
    root.panel["canister_reserves_flow"].children[1].sprite = "item/" .. current_fuel.name
    root.panel["canister_reserves_flow"].children[1].tooltip = {"space-exploration.jetpack_reserves_canisters_tooltip"}

    -- current fuel item left in inventory
    root.panel["canister_reserves_flow"]["lifesupport_canisters"].caption = player.character.get_main_inventory().get_item_count(current_fuel.name)
    root.panel["canister_reserves_flow"]["lifesupport_canisters"].tooltip = {"space-exploration.jetpack_reserves_canisters_tooltip"}

    -- thrust percentage of the current fuel item
    root.panel["canister_reserves_flow"]["lifesupport_efficiency"].caption = string.format("×%.f%%", current_fuel.thrust * 100)
    root.panel["canister_reserves_flow"]["lifesupport_efficiency"].tooltip = {"space-exploration.jetpack_efficiency_tooltip"}

    -- just put some vaguely interesting information in the info dot
    local x = (Jetpack.fuel_use_base + Jetpack.fuel_use_thrust) / Jetpack.fuel_use_base
    root.panel.time_reserves_flow.info.tooltip = "Flying takes " .. x .. "x more fuel than hovering."
  end
end

function JetpackGUI.sum_fuel_energy_from_inventory(character)
  local energy = 0

  local inventory = character.get_main_inventory()
  if inventory and inventory.valid then
    for fuel_name, fuel_stats in pairs(storage.compatible_fuels) do
      if prototypes.item[fuel_name] then
        local count = inventory.get_item_count(fuel_name)
        if count > 0 then
          energy = energy + fuel_stats.energy * count
        end
      end
    end
  end

  return energy
end

script.on_init(JetpackGUI.on_init)
script.on_configuration_changed(JetpackGUI.on_configuration_changed)
script.on_nth_tick(Lifesupport.nth_tick_interval, JetpackGUI.on_nth_tick)

-- events that (can) call Lifesupport.gui_update (and thus cause the gui to refresh/reset prematurely)
script.on_event(defines.events.on_player_placed_equipment,        JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_removed_equipment,       JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_armor_inventory_changed, JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_changed_surface,         JetpackGUI.on_lifesupport_gui_refreshed)
script.on_event(defines.events.on_player_driving_changed_state,   JetpackGUI.on_lifesupport_gui_refreshed)
