require("shared")

-- we depend on this recipe being default
assert( prototypes.recipe["wooden-chest"])
assert( prototypes.recipe["wooden-chest"].enabled)
assert(#prototypes.recipe["wooden-chest"].ingredients == 1)
assert( prototypes.recipe["wooden-chest"].ingredients[1].type == "item")
assert( prototypes.recipe["wooden-chest"].ingredients[1].name == "wood")
assert( prototypes.recipe["wooden-chest"].ingredients[1].amount == 2)

local pollution_filter_item = "kr-pollution-filter"
if not prototypes.item["kr-pollution-filter"] then
  pollution_filter_item = "pollution-filter"
end

function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

function next_x_offset()
  storage.x_offset = storage.x_offset + 3
  return storage.x_offset - 3
end

local mod = {}

script.on_init(function()
  storage.surface = game.planets[mod_name].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.surface.create_global_electric_network()
  storage.surface.create_entity{
    name = "electric-energy-interface",
    force = "neutral",
    position = {-1, -1},
  }

  storage.x_offset = 0
  storage.structs = {}

  storage.deathrattles = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {"kr-air-purifier"}})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

mod.on_created_entity_filters = {
  {filter = "name", name = "kr-air-purifier"},
}

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,

    entity = entity,
    proxy_container = nil,
    assembling_machine = nil,

    furnace_source_stack = entity.get_inventory(defines.inventory.furnace_source)[1],
    furnace_result_stack = entity.get_inventory(defines.inventory.furnace_result)[1],

    assembling_machine_input_stack  = nil,
    assembling_machine_output_stack = nil,

    x_offset = next_x_offset(),
  })

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = struct.id, name = "entity"}

  struct.proxy_container = storage.surface.create_entity{
    name = "proxy-container",
    force = "neutral",
    position = {1.5 + struct.x_offset, -0.5},
  }
  struct.proxy_container.proxy_target_entity = struct.entity
  struct.proxy_container.proxy_target_inventory = defines.inventory.furnace_source

  struct.assembling_machine = storage.surface.create_entity{
    name = "assembling-machine-1",
    force = "neutral",
    position = {1.5 + struct.x_offset, -2.5},
  }
  struct.assembling_machine.set_recipe("wooden-chest")
  struct.assembling_machine_input_stack  = struct.assembling_machine.get_inventory(defines.inventory.assembling_machine_input)[1]
  struct.assembling_machine_output_stack = struct.assembling_machine.get_inventory(defines.inventory.assembling_machine_output)[1]

  local red_out  =  struct.proxy_container.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  local red_in = struct.assembling_machine.get_wire_connector(defines.wire_connector_id.circuit_red, true)
  assert(red_out.connect_to(red_in))

  local cb = struct.assembling_machine.get_control_behavior() --[[@as LuaAssemblingMachineControlBehavior]]
  cb.circuit_enable_disable = true
---@diagnostic disable-next-line: missing-fields
  cb.circuit_condition = {
    comparator = "=",
    constant = 0,
    first_signal = {
      name = "signal-everything",
      type = "virtual"
    },
  }

  mod.tick_struct(struct)
end

local function new_insert_plan()
  return {
    id = {name = pollution_filter_item},
    items = {in_inventory = {
      {inventory = defines.inventory.furnace_source, stack = 0, count = 1},
    }}
  }
end

local function insert_plan_requests_filters(insert_plan)
  return insert_plan.id.name == pollution_filter_item
end

local function ensure_a_proxy_is_requesting_filters(struct)
  local entity = struct.entity
  local proxy = entity.item_request_proxy

  if proxy == nil then
    proxy = entity.surface.create_entity{
      name = "item-request-proxy",
      force = entity.force,
      position = entity.position,

      target = entity,
      modules = {new_insert_plan()},
    }
  else
    local insert_plans = proxy.insert_plan
    for _, insert_plan in ipairs(insert_plans) do
      if insert_plan_requests_filters(insert_plan) then
        return
      end
    end

    table.insert(insert_plans, new_insert_plan())
    proxy.insert_plan = insert_plans
  end

  storage.deathrattles[script.register_on_object_destroyed(proxy)] = {struct_id = struct.id, name = "proxy"}
end

function mod.tick_struct(struct)
  if not struct.furnace_source_stack.valid_for_read then
      if struct.entity.valid then
        ensure_a_proxy_is_requesting_filters(struct)
      end
    else
      struct.assembling_machine_output_stack.clear()
      struct.assembling_machine_input_stack.set_stack({
        name = "wood",
        count = 2,
        health = 0.5,
      })
      storage.deathrattles[script.register_on_object_destroyed(struct.assembling_machine_input_stack.item)] = {struct_id = struct.id, name = "wood"}
  end
end

function mod.try_to_take_out_used_filters(struct)
  if not struct.furnace_result_stack.valid_for_read then return end

  local entity = struct.entity
  local nearby_construction_robots = entity.surface.find_entities_filtered{
    type = "construction-robot",
    position = entity.position,
    force = entity.force,
    limit = 1,
  }
  if #nearby_construction_robots > 0 then
    local cargo = nearby_construction_robots[1].get_inventory(defines.inventory.robot_cargo)
    if not cargo.is_empty() then return end

    struct.furnace_result_stack.swap_stack(cargo[1])
  else
    local removal_plan = {
      {id = {name = "kr-used-pollution-filter"}, items = {in_inventory = {
        {inventory = defines.inventory.furnace_result, stack = 0, count = struct.furnace_result_stack.count}
      }}}
    }
    local proxy = entity.item_request_proxy
    if proxy then
      proxy.removal_plan = removal_plan
    else
      entity.surface.create_entity{
        name = "item-request-proxy",
        force = entity.force,
        position = entity.position,

        target = entity,
        modules = {},
        removal_plan = removal_plan
      }
    end
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

local deathrattles = {
  ["entity"] = function (deathrattle)
    local struct = storage.structs[deathrattle.struct_id]
    storage.structs[deathrattle.struct_id] = nil

    struct.proxy_container.destroy()
    struct.assembling_machine.destroy()
  end,
  ["proxy"] = function (deathrattle)
    local struct = storage.structs[deathrattle.struct_id]
    if struct and struct.entity.valid then
      -- game.print("proxy")
      mod.try_to_take_out_used_filters(struct)
      mod.tick_struct(struct)
    end
  end,
  ["wood"] = function (deathrattle)
    local struct = storage.structs[deathrattle.struct_id]
    if struct then
      -- game.print("wood")
      mod.tick_struct(struct)
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle.name](deathrattle)
  end
end)
