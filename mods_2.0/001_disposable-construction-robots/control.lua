require("namespace")

local function setup_surface()
  if storage.surface then return end

  storage.surface = game.planets[mod_name].create_surface()
  storage.surface.generate_with_lab_tiles = true
  storage.surface.global_effect = {speed = 60}

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }
end

script.on_init(function()
  setup_surface()

  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  setup_surface()

  storage.structs = storage.structs or {}
  storage.deathrattles = storage.deathrattles or {}
end)

local function try_to_give_player_personal_roboport(player)
  local armorslot = player.get_inventory(defines.inventory.character_armor)

  -- armorslot can be nil whilst the player is in remote view
  if armorslot and armorslot.is_empty() then
    -- not valid whilst there is a hand in their pants
    if armorslot.insert({name = "empty-ish-armor-slot"}) and armorslot[1].valid_for_read then
      armorslot[1].grid.put{name = "disposable-roboport-equipment"}
    end
  end
end

script.on_event(defines.events.on_player_crafted_item, function(event)
  if event.item_stack.valid_for_read == false then return end
  if event.item_stack.name ~= "disposable-construction-robot" then return end

  local player = game.get_player(event.player_index)
  try_to_give_player_personal_roboport(player)
end)

-- prevent players from ctrl clicking it into their main inventory,
-- unfortunately doesn't work when you grab it with your hand.
script.on_event(defines.events.on_player_armor_inventory_changed, function(event)
  local player = assert(game.get_player(event.player_index))

  player.get_inventory(defines.inventory.character_main).remove({name = "empty-ish-armor-slot"})
  if player.cursor_stack.valid_for_read and player.cursor_stack.name == "empty-ish-armor-slot" then player.cursor_stack.clear() end

  -- commented out since the hand cannot easily be dealt with, and it refreshes when you craft new bots anyways.
  -- try_to_give_player_personal_roboport(player)
end)

local function arm_for_anything(struct)
  struct.assembling_machine_cb.circuit_condition = {
    comparator = ">",
    constant = 0,
    first_signal = {
      type = "virtual",
      name = "signal-anything",
    }
  }

  -- struct.assembling_machine_stack_out.clear()
  struct.assembling_machine_stack_in.set_stack({
    name = "wood",
    count = 2,
    health = 0.5,
  })

  storage.deathrattles[script.register_on_object_destroyed(struct.assembling_machine_stack_in.item)] = {name = "stack", struct_id = struct.id}
end

local function arm_for_nothing(struct)
  struct.assembling_machine_cb.circuit_condition = {
    comparator = "=",
    constant = 0,
    first_signal = {
      type = "virtual",
      name = "signal-everything",
    }
  }

  -- struct.assembling_machine_stack_out.clear()
  struct.assembling_machine_stack_in.set_stack({
    name = "wood",
    count = 2,
    health = 0.5,
  })

  storage.deathrattles[script.register_on_object_destroyed(struct.assembling_machine_stack_in.item)] = {name = "stack", struct_id = struct.id}
end

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "disposable-construction-robot-created" then return end

  local entity = event.source_entity
  assert(entity)

  local assembling_machine = storage.surface.create_entity{
    name = "assembling-machine-1",
    force = "neutral",
    position = {1.5, -1.5},
  }
  assert(assembling_machine)
  assembling_machine.set_recipe("wooden-chest")
  local cb = assembling_machine.get_or_create_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  cb.circuit_enable_disable = true


  local proxy_container = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {0.5, 0.5},
  }
  assert(proxy_container)
  proxy_container.proxy_target_entity = entity
  proxy_container.proxy_target_inventory = defines.inventory.robot_cargo

  local red_in = assembling_machine.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local red_out = proxy_container.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(red_in.connect_to(red_out))

  storage.structs[entity.unit_number] = {
    id = entity.unit_number,
    entity = entity,
    cargo = entity.get_inventory(defines.inventory.robot_cargo)[1],

    assembling_machine = assembling_machine,
    assembling_machine_cb = cb,
    assembling_machine_stack_in = assembling_machine.get_inventory(defines.inventory.crafter_input)[1],
    -- assembling_machine_stack_out = assembling_machine.get_inventory(defines.inventory.crafter_output)[1],

    proxy_container = proxy_container,
  }

  arm_for_anything(storage.structs[entity.unit_number])
  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "entity", struct_id = entity.unit_number}
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "stack" then
      local struct = storage.structs[deathrattle.struct_id]
      if struct then
        if struct.cargo.valid_for_read then
          arm_for_nothing(struct)
        else
          struct.entity.die(struct.entity.force)
        end
      end
    elseif deathrattle.name == "entity" then
      local struct = storage.structs[deathrattle.struct_id]
      storage.structs[deathrattle.struct_id] = nil
      struct.assembling_machine.destroy()
      struct.proxy_container.destroy()
    else
      error(serpent.block(deathrattle))
    end
  end
end)
