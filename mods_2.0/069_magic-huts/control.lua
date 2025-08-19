require("util")
require("shared")
require("scripts.factoryplanner")
require("scripts.luagui-pretty-print")

Factories = require("scripts.factories")
Buildings = require("scripts.buildings")
Planet = require("scripts.planet")
Crafter = require("scripts.crafter")

script.on_event(defines.events.on_gui_opened, function(event)
  Factoryplanner.on_gui_opened(event)
end)

script.on_event(defines.events.on_gui_click, function(event)
  -- log(LuaGuiPrettyPrint.path_to_element(event.element))

  if event.element.name == mod_prefix .. "summon-magic-hut" then
    Factoryplanner.on_gui_click(event)
  end

  if event.element.tags.action then
    Factories.on_gui_click(event)
  end
end)

mod = {}

mod.container_name_to_tier = {}
mod.tier_to_container_name = {}
mod.container_name_to_crafter_a_name = {}
mod.container_name_to_crafter_b_name = {}
mod.container_name_to_eei_name = {}
mod.container_names_list = {}
mod.on_created_entity_filter = {}

for i = 1, 6 do
  mod.container_name_to_tier[mod_prefix .. "container-" .. i] = i
  mod.tier_to_container_name[i] = mod_prefix .. "container-" .. i
  mod.container_name_to_crafter_a_name[mod_prefix .. "container-" .. i] = mod_prefix .. "crafter-a-" .. i
  mod.container_name_to_crafter_b_name[mod_prefix .. "container-" .. i] = mod_prefix .. "crafter-b-" .. i
  mod.container_name_to_eei_name[mod_prefix .. "container-" .. i] = mod_prefix .. "eei-" .. i
  table.insert(mod.container_names_list, mod_prefix .. "container-" .. i)
  table.insert(mod.on_created_entity_filter, {      filter = "name", name = mod_prefix .. "container-" .. i})
  table.insert(mod.on_created_entity_filter, {filter = "ghost_name", name = mod_prefix .. "container-" .. i})
end

mod.container_names_map = util.list_to_map(mod.container_names_list)

mod.mouse_button_to_tier = {
  [defines.mouse_button_type.left  ] = 1,
  [defines.mouse_button_type.middle] = 2,
  [defines.mouse_button_type.right ] = 3,
}

mod.next_index_for = function(key)
  local id = (storage.index[key] or 0) + 1
  storage.index[key] = id
  return id
end

script.on_init(function()
  storage.invalid = game.create_inventory(0)
  storage.invalid.destroy()

  storage.index = {} -- {string -> number}

  storage.factories = {} -- {number -> struct}
  storage.buildings = {} -- {unit_number -> struct}

  storage.deathrattles = {}

  storage.surface = game.planets[mod_name].create_surface()
  storage.surface.generate_with_lab_tiles = true
  storage.surface.global_effect = {speed = 60}

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.playerdata = {}
  for _, player in pairs(game.players) do
    mod.on_player_created({player_index = player.index})
  end
end)

script.on_configuration_changed(function()
  for _, player in pairs(game.players) do
    mod.recreate_relative_gui(player)
  end
end)

mod.relative_frame_left_name = mod_prefix .. "frame-left"
mod.relative_frame_right_name = mod_prefix .. "frame-right"

mod.on_player_created = function (event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  storage.playerdata[player.index] = {
    player = player,
    held_factory_index = nil,
  }

  mod.recreate_relative_gui(player)
end

mod.recreate_relative_gui = function(player)
  local frame = player.gui.relative[mod.relative_frame_left_name]
  if frame then frame.destroy() end

  frame = player.gui.relative.add{
    type = "frame",
    name = mod.relative_frame_left_name,
    anchor = {
      gui = defines.relative_gui_type.container_gui,
      position = defines.relative_gui_position.left,
      names = mod.container_names_list,
    },
  }
  frame.style.top_padding = 8

  local inner = frame.add{
    type = "frame",
    name = "inner",
    style = "inside_shallow_frame",
    direction = "vertical",
  }

  local scroll_pane = inner.add{
    type = "scroll-pane",
    name = "scroll-pane",
    style = "list_box_scroll_pane",
    vertical_scroll_policy = "always",
  }
  scroll_pane.style.padding = 1
  scroll_pane.style.top_padding = 4
  scroll_pane.style.bottom_padding = 4
  scroll_pane.style.vertically_stretchable = true
  scroll_pane.style.minimal_width = 340 + 14 -- to make sure it is not thin when empty
end

mod.on_player_removed = function (event)
  storage.playerdata[event.player_index] = nil
end

script.on_event(defines.events.on_player_created, mod.on_player_created)
script.on_event(defines.events.on_player_removed, mod.on_player_removed)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Buildings.on_created_entity, mod.on_created_entity_filter)
end

mod.player_holding_hut = function(player)
  local held_item = (player.cursor_stack.valid_for_read and player.cursor_stack) or (player.cursor_ghost and player.cursor_ghost.name)
  return held_item and mod.container_names_map[held_item.name]
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "trigger" then
      local building = storage.buildings[deathrattle.building_index]
      if building then
        local n = deathrattle.n
        if n == 1 then
          -- game.print("working")
          Planet.arm_trigger_n(building, 2)
          Buildings.set_status(building, "[img=utility/status_working] working")
          Buildings.turn_eei_on(building) -- would ask for power if you took a building out for a bit, even if the power got paid already
        elseif n == 2 then
          -- game.print("waiting for items")
          Planet.arm_trigger_n(building, 1)
          Buildings.set_status(building, "[img=utility/status_not_working] missing construction items")
          Buildings.turn_eei_off(building)
        elseif n == 3 then
          -- game.print("recipe finished")
          Planet.arm_trigger_n(building, 3)
          Crafter.craft(building)
        end
      end
    elseif deathrattle.name == "building" then
      local building = storage.buildings[event.useful_id]
      if building then storage.buildings[event.useful_id] = nil
        local factory = storage.factories[building.factory_index]
        if factory then
          factory.count = factory.count - 1
          Factories.refresh_list()
        end
        for _, child in pairs(building.children) do
          child.destroy() -- compound entity & hidden surface
        end
      end
    end
  end
end)

local function fh_add_items_drop_target_entity(target, items)
  local building = storage.buildings[target.unit_number]
  local factory = storage.factories[building.factory_index]

  if factory then
    for _, key in ipairs({"ingredients"}) do
      for _, item in ipairs(factory.export[key]) do
        if item.type == "item" then
          table.insert(items, {name = item.name, quality = item.quality})
        end
      end
    end
  end

  return items
end

local function fh_add_items_pickup_target_entity(target, items)
  local building = storage.buildings[target.unit_number]
  local factory = storage.factories[building.factory_index]

  if factory then
    for _, key in ipairs({"products", "byproducts"}) do
      for _, item in ipairs(factory.export[key]) do
        if item.type == "item" then
          table.insert(items, {name = item.name, quality = item.quality})
        end
      end
    end
  end

  return items
end

remote.add_interface("magic-huts", {
  fh_add_items_drop_target_entity = fh_add_items_drop_target_entity,
  fh_add_items_pickup_target_entity = fh_add_items_pickup_target_entity,
})
