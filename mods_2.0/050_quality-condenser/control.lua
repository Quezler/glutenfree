require("shared")
mod_prefix = "quality-condenser--"

local Combinators = require("scripts.combinators")

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function reset_offering_idle(struct)
  if struct.inserter_1_offering.valid then return end
  -- game.print(string.format("resetting offering idle for #%d @ %d", struct.id, game.tick))
  struct.inserter_1.held_stack.clear()
  struct.inserter_1_offering = storage.surface.create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {0.5 + struct.index, -8.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_1_offering)] = {"offering-idle", struct.id}
end

local function reset_offering_done(struct)
  if struct.inserter_2_offering.valid then return end
  -- game.print(string.format("resetting offering done for #%d @ %d", struct.id, game.tick))
  struct.inserter_2.held_stack.clear()
  struct.inserter_2_offering = storage.surface.create_entity{
    name = "item-on-ground",
    force = "neutral",
    position = {0.5 + struct.index, -11.5},
    stack = {name = "wood"},
  }
  storage.deathrattles[script.register_on_object_destroyed(struct.inserter_2_offering)] = {"offering-done", struct.id}
end

local function spill_entity_inventory(entity, defines_inventory)
  local inventory = entity.get_inventory(defines_inventory)

  for slot = 1, #inventory do
    local stack = inventory[slot]
    if stack.valid_for_read then
      entity.surface.spill_item_stack{
        position = entity.position,
        stack = stack,
        force = entity.force,
        allow_belts = false,
      }
    end
  end

  inventory.clear()
end

local technology_changes_quality = {}
for _, technology in pairs(prototypes.technology) do
  local sum = 0
  for _, effect in pairs(technology.effects) do
    if effect.type == "nothing" then
      local effect_description = effect.effect_description[1]
      if effect_description and type(effect_description) == "string" and effect_description == "effect-description.quality-condenser-quality" then
        sum = sum + tonumber(effect.effect_description[3])
      end
    end
  end
  if sum ~= 0 then
    technology_changes_quality[technology.name] = sum
  end
end
log("technology_changes_quality = " .. serpent.block(technology_changes_quality))

local function get_bonus_quality(force)
  if table_size(technology_changes_quality) == 0 then return 0 end

  local sum = 0

  for technology_name, technology in pairs(force.technologies) do
    if technology_changes_quality[technology_name] and technology.researched then
      sum = sum + technology_changes_quality[technology_name]
    end
  end

  return sum * 10 -- technology_changes_quality is in 0-100 decimal format, we need it in 0-1000 format
end

local Handler = {}

function Handler.refresh_gui_for_player(player)
  for _, relative_gui in ipairs(player.gui.relative.children) do
    if relative_gui.get_mod() == mod_name then
      relative_gui.destroy()
    end
  end

  do
    local tabbed_pane = player.gui.relative.add{
      name = mod_prefix .. "tabbed-pane-modules",
      type = "tabbed-pane",
      style = "quality_condenser_tabbed_pane",
      anchor = {
        gui = defines.relative_gui_type.assembling_machine_gui,
        position = defines.relative_gui_position.top,
        name = "quality-condenser",
      }
    }
    tabbed_pane.style.horizontally_stretchable = true

    local tab1 = tabbed_pane.add{type="tab", caption="Modules"}
    local tab2 = tabbed_pane.add{type="tab", caption="Inventory"}
    local label1 = tabbed_pane.add{type="empty-widget"}
    local label2 = tabbed_pane.add{type="empty-widget"}
    tabbed_pane.add_tab(tab1, label1)
    tabbed_pane.add_tab(tab2, label2)
    tabbed_pane.selected_tab_index = 1
  end

  do
    local tabbed_pane = player.gui.relative.add{
      name = mod_prefix .. "tabbed-pane-inventory",
      type = "tabbed-pane",
      style = "quality_condenser_tabbed_pane",
      anchor = {
        gui = defines.relative_gui_type.container_gui,
        position = defines.relative_gui_position.top,
        name = "quality-condenser--container",
      }
    }
    tabbed_pane.style.horizontally_stretchable = true

    local tab1 = tabbed_pane.add{type="tab", caption="Modules"}
    local tab2 = tabbed_pane.add{type="tab", caption="Inventory"}
    local label1 = tabbed_pane.add{type="empty-widget"}
    local label2 = tabbed_pane.add{type="empty-widget"}
    tabbed_pane.add_tab(tab1, label1)
    tabbed_pane.add_tab(tab2, label2)
    tabbed_pane.selected_tab_index = 2
  end
end

function Handler.refresh_gui_for_players()
  for _, player in pairs(game.players) do
    Handler.refresh_gui_for_player(player)
  end
end

script.on_init(function()
  storage.surface = game.planets["quality-condenser"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  -- {valid = false, destroy = function () end}
  storage.invalid = storage.surface.create_entity{
    name = "small-electric-pole",
    force = "neutral",
    position = {-2.5, -0.5},
  }
  storage.invalid.destroy()

  storage.index = 0
  storage.structs = {}
  storage.deathrattles = {}

  Handler.refresh_gui_for_players()
end)

local function update_beacon_interface(struct, bonus_quality)
  remote.call("beacon-interface", "set_effects", struct.beacon_interface.unit_number, {
    speed = 0,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = get_base_quality(struct.entity.quality) + (bonus_quality or get_bonus_quality(struct.entity.force)),
  })
end

script.on_configuration_changed(function(data)
  for _, struct in pairs(storage.structs) do
    update_beacon_interface(struct)
  end

  Handler.refresh_gui_for_players()
end)

function ensure_recipe_is_set(entity)
  local recipe, quality = entity.get_recipe()
  if recipe == nil then entity.set_recipe(mod_prefix .. "a-whole-bunch-of-items") end
  return quality or prototypes.quality["normal"]
end

local allow_beacon_interface_creation = false

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  -- mods to not get to clone/place the container.
  if entity.name == mod_prefix .. "container" then
    spill_entity_inventory(entity, defines.inventory.chest)
    entity.destroy()
    return
  elseif entity.name == mod_prefix .. "beacon-interface" then
    if allow_beacon_interface_creation == false then
      entity.destroy()
    end
    return
  end

  ensure_recipe_is_set(entity)

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    index = storage.index,
    entity = entity,

    beacon_interface = nil,
    container = nil,
    container_inventory = nil,
    arithmetic_1 = nil, -- each + 0 = S
    arithmetic_2 = nil, -- each + 0 = each
    decider_1 = nil, -- red T != green T | R 1
    decider_2 = nil, -- R == 0 | T = T + 1
    inserter_1 = nil, -- T = ?
    inserter_1_offering = storage.invalid,
    inserter_2 = nil, -- F > 0
    inserter_2_offering = storage.invalid,
  })
  storage.index = storage.index + 1

  allow_beacon_interface_creation = true
  struct.beacon_interface = entity.surface.create_entity{
    name = mod_prefix .. "beacon-interface",
    force = entity.force,
    position = entity.position,
    raise_built = true,
  }
  allow_beacon_interface_creation = false
  struct.beacon_interface.destructible = false
  update_beacon_interface(struct)

  local other_quality_container = entity.surface.find_entities_filtered{
    name = mod_prefix .. "container",
    force = entity.force,
    position = entity.position,
    limit = 1,
  }[1]

  struct.container = entity.surface.create_entity{
    name = mod_prefix .. "container",
    force = entity.force,
    position = entity.position,
    quality = entity.quality,
  }
  struct.container.destructible = false
  struct.container_inventory = struct.container.get_inventory(defines.inventory.chest)

  if other_quality_container then
    local other_quality_container_inventory = other_quality_container.get_inventory(defines.inventory.chest)
    for slot = 1, #other_quality_container_inventory do
      local stack = other_quality_container_inventory[slot]
      if stack.valid_for_read then
        stack.count = stack.count - struct.container_inventory.insert(stack)
      end
    end
  end

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {"crafter", struct.id}
  storage.deathrattles[script.register_on_object_destroyed(struct.container)] = {"container", struct.id}

  Combinators.create_for_struct(struct)
  reset_offering_idle(struct)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = mod_name},
    {filter = "name", name = mod_prefix .. "container"},
    {filter = "name", name = mod_prefix .. "beacon-interface"},
  })
end

local Condense = require("scripts.condense")

local deathrattles = {
  ["offering-idle"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      reset_offering_idle(struct)
      if struct.entity.crafting_progress == 0 and struct.container_inventory.is_empty() == false then
        ensure_recipe_is_set(struct.entity)
        struct.entity.crafting_progress = 0.001
        reset_offering_done(struct)
      end
    end
  end,
  ["offering-done"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      Condense.trigger(struct)
      reset_offering_idle(struct)
    end
  end,
  ["crafter"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      storage.structs[struct.id] = nil
      if struct.container_inventory.valid then
        spill_entity_inventory(struct.container, defines.inventory.chest)
      end
      -- struct.entity.destroy()
      struct.beacon_interface.destroy()
      struct.container.destroy()
      struct.arithmetic_1.destroy()
      struct.arithmetic_2.destroy()
      struct.decider_1.destroy()
      struct.decider_2.destroy()
      struct.inserter_1.destroy()
      struct.inserter_1_offering.destroy()
      struct.inserter_2.destroy()
      struct.inserter_2_offering.destroy()
    end
  end,
  ["container"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      storage.structs[struct.id] = nil
      if struct.entity.valid then
        spill_entity_inventory(struct.entity, defines.inventory.assembling_machine_modules)
      end
      struct.entity.destroy()
      struct.beacon_interface.destroy()
      -- struct.container.destroy()
      struct.arithmetic_1.destroy()
      struct.arithmetic_2.destroy()
      struct.decider_1.destroy()
      struct.decider_2.destroy()
      struct.inserter_1.destroy()
      struct.inserter_1_offering.destroy()
      struct.inserter_2.destroy()
      struct.inserter_2_offering.destroy()
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle[1]](deathrattle)
  end
end)

script.on_nth_tick(60 * 60, function(event)
  for _, struct in pairs(storage.structs) do
    local signal_T = struct.inserter_1.get_signal({type = "virtual", name = "signal-T"}, defines.wire_connector_id.circuit_green)
    if signal_T > 300 then -- idle for over 5 seconds
      if struct.entity.crafting_progress == 0 and struct.container_inventory.is_empty() == false then -- is currently not crafting
        ensure_recipe_is_set(struct.entity)
        struct.entity.crafting_progress = 0.001
      end
    end
  end
end)

local function on_research_toggled(event)
  if technology_changes_quality[event.research.name] then
    local force = event.research.force
    local bonus_quality = get_bonus_quality(force)
    for _, struct in pairs(storage.structs) do
      if struct.entity.force == force then
        update_beacon_interface(struct, bonus_quality)
      end
    end
  end
end

script.on_event(defines.events.on_research_finished, on_research_toggled)
script.on_event(defines.events.on_research_reversed, on_research_toggled)

script.on_event(defines.events.on_gui_selected_tab_changed, function(event)
  if event.element.name == mod_prefix .. "tabbed-pane-modules" then
    if event.element.selected_tab_index == 1 then return end
    event.element.selected_tab_index = 1
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local entity = player.opened --[[@as LuaEntity]]
    if player.opened_gui_type == defines.gui_type.entity and entity.name == mod_name then
      player.opened = entity.surface.find_entities_filtered{
        name = mod_prefix .. "container",
        force = entity.force,
        position = entity.position,
        limit = 1,
      }[1]
    end
  elseif event.element.name == mod_prefix .. "tabbed-pane-inventory" then
    if event.element.selected_tab_index == 2 then return end
    event.element.selected_tab_index = 2
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local entity = player.opened --[[@as LuaEntity]]
    if player.opened_gui_type == defines.gui_type.entity and entity.name == mod_prefix .. "container" then
      player.opened = entity.surface.find_entities_filtered{
        name = mod_name,
        force = entity.force,
        position = entity.position,
        limit = 1,
      }[1]
    end
  end
end)
