local config = require("config")

local Buildings = {}

local function get_factory_index(event)
  local entity = event.entity or event.destination

  if event.player_index and storage.playerdata[event.player_index] then
    local held_factory_index = storage.playerdata[event.player_index].held_factory_index
    if held_factory_index then -- if nil, go for checking the ghost tags
      return held_factory_index
    end
  end

  if event.tags and event.tags[mod_prefix .. "factory-index"] then
    return event.tags[mod_prefix .. "factory-index"]
  end

  if entity.tags and entity.tags[mod_prefix .. "factory-index"] then
    return entity.tags[mod_prefix .. "factory-index"]
  end

  if entity.last_user and storage.playerdata[entity.last_user.index] then
    return storage.playerdata[entity.last_user.index].held_factory_index
  end

  return nil
end

Buildings.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local factory_index = get_factory_index(event)

  if entity.type == "entity-ghost" then
    if factory_index then
      local tags = entity.tags or {}
      tags[mod_prefix .. "factory-index"] = factory_index
      entity.tags = tags
    end
  end

  -- if not factory_index then return end
  -- local factory = storage.factories[factory_index]
  -- if not factory then return end

  local entity_name = get_entity_name(entity)
  local building = new_struct(storage.buildings, {
    index = entity.unit_number,
    x_offset = nil,
    entity = entity,
    is_ghost = entity.type == "entity-ghost",

    inventory = entity.get_inventory(defines.inventory.chest),
    -- inventory_size = prototypes.entity[entity_name].get_inventory_size(defines.inventory.chest, entity.quality),

    line_1 = nil,
    line_2 = nil,
    line_3 = nil,
    line_4 = nil,

    children = {},
    factory_new = true,
    factory_index = nil,

    item_input_buffer = {},
    fluid_input_buffer = {},
    item_output_buffer = {},
    fluid_output_buffer = {},
  })

  local factory_config = config.factories[mod.container_name_to_tier[entity_name]]

  building.line_1 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_name},
    alignment = "center",
    use_rich_text = true,
    scale = 1,
  }

  building.line_2 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_description},
    alignment = "center",
    use_rich_text = true,
    scale = 0.5,
  }

  building.line_3 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_message},
    alignment = "center",
    use_rich_text = true,
    scale = 1,
  }

  building.line_4 = rendering.draw_text{
    text = "",
    color = {1, 1, 1},
    surface = entity.surface,
    target = {entity = entity, offset = factory_config.offset_verbose},
    alignment = "center",
    use_rich_text = true,
    scale = 0.5,
  }

  if not building.is_ghost then
    building.children.crafter_a = entity.surface.create_entity{
      name = mod.container_name_to_crafter_a_name[entity.name],
      force = entity.force,
      position = entity.position,
      create_build_effect_smoke = false,
    }
    building.children.crafter_a.destructible = false

    building.children.crafter_b = entity.surface.create_entity{
      name = mod.container_name_to_crafter_b_name[entity.name],
      force = entity.force,
      position = entity.position,
      create_build_effect_smoke = false,
    }
    building.children.crafter_b.destructible = false

    building.children.eei = entity.surface.create_entity{
      name = mod.container_name_to_eei_name[entity.name],
      force = entity.force,
      position = entity.position,
      create_build_effect_smoke = false,
    }
    building.children.eei.destructible = false
  end

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {name = "building", building_index = building.index}

  Planet.setup_combinators(building)
  Buildings.set_factory_index(building, factory_index)
end

Buildings.set_status_not_configured = function(building)
  building.line_1.text = ""
  building.line_2.text = ""
  building.line_3.text = "[img=utility/status_inactive] not configured"
  building.line_4.text = "head into factory planner and export a factory"
end

local function get_description(factory)
  local description = ""

  for _, product in ipairs(factory.export.products) do
    description = description .. string.format("[%s=%s]", product.type, product.name)
  end
  description = description .. " - "

  if #factory.export.byproducts > 0 then
    for _, byproduct in ipairs(factory.export.byproducts) do
      description = description .. string.format("[%s=%s]", byproduct.type, byproduct.name)
    end
    description = description .. " - "
  end

  for _, ingredient in ipairs(factory.export.ingredients) do
    description = description .. string.format("[%s=%s]", ingredient.type, ingredient.name)
  end

  return description
end

Buildings.set_factory_index = function (building, factory_index)
  if building.factory_index == factory_index and not building.factory_new then return end
  building.factory_new = false

  if building.factory_index then
    local old_factory = storage.factories[building.factory_index]
    old_factory.count = old_factory.count - 1
  end

  building.factory_index = factory_index
  Buildings.turn_eei_off(building)

  if building.factory_index == nil then
    Buildings.set_status_not_configured(building)
    Planet.update_constant_combinator_1(building)
    Factories.refresh_list()
    return
  end

  local factory = storage.factories[building.factory_index]
  factory.count = factory.count + 1
  Factories.refresh_list()

  building.line_1.text = factory.export.name
  building.line_2.text = get_description(factory)
  building.line_3.text = "[img=utility/status_not_working] not yet implemented"
  building.line_4.text = "Quezler is still working hard on the rest"

  local filters = Buildings.get_filters(building)
  log(string.format("filtering %d slots for factory #%d (%s)", #filters, factory.index, factory.export.name))
  Buildings.set_filters(building, filters)
  Buildings.set_insert_plan(building, Buildings.get_insert_plan(building))
  Planet.update_constant_combinator_1(building)
  Crafter.inflate_buffers(building)
end

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  local blueprint = event.stack
  if blueprint == nil then return end

  local blueprint_entities = blueprint.get_blueprint_entities() or {}
  for i, blueprint_entity in ipairs(blueprint_entities) do
    if mod.container_names_map[blueprint_entity.name] then
      local entity = event.mapping.get()[i]
      local factory_index = storage.buildings[entity.unit_number].factory_index
      if factory_index then
        blueprint.set_blueprint_entity_tag(i, mod_prefix .. "factory-index", factory_index)
      end
    end
  end
end)

-- script.on_event(defines.events.on_player_pipette, function(event)
--   local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
--   local selected = player.selected
--   if not selected then return end

--   local entity_name = selected.type == "entity-ghost" and selected.ghost_name or selected.name
--   if not mod.container_names_map[entity_name] then return end

--   local factory_index = storage.buildings[selected.unit_number].factory_index
--   if factory_index then
--     storage.playerdata[player.index].held_factory_index = factory_index
--   end
-- end)

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if mod.container_names_map[get_entity_name(event.source)] and mod.container_names_map[get_entity_name(event.destination)] then
    local building_a = storage.buildings[event.source.unit_number]
    local building_b = storage.buildings[event.destination.unit_number]

    Buildings.set_factory_index(building_b, building_a.factory_index)
  end
end)

Buildings.get_filters_from_export = function(export)
  local filters = {}

  for _, key in ipairs({"entities", "modules", "ingredients", "byproducts", "products"}) do
    for _, item in ipairs(export[key]) do
      if item.type == "item" then
        local slots = math.ceil(item.count / prototypes.item[item.name].stack_size)
        for i = 1, slots do
          table.insert(filters, {name = item.name, quality = item.quality})
        end
      end
    end
  end

  return filters
end

Buildings.get_filters = function(building)
  local factory = storage.factories[building.factory_index]
  if not factory then return {} end

  return Buildings.get_filters_from_export(factory.export)
end

Buildings.get_insert_plan = function(building)
  local factory = storage.factories[building.factory_index]
  if not factory then return {} end

  local insert_plan = {}
  local slot = 0

  for _, key in ipairs({"entities", "modules"}) do
    for _, item in ipairs(factory.export[key]) do
      if item.type == "item" then
        local count = item.count
        local stack_size = prototypes.item[item.name].stack_size
        local ip = {
          id = {name = item.name, quality = item.quality},
          items = {in_inventory = {
            --
          }}
        }
        while count > 0 do
          local subtract = math.min(count, stack_size)
          table.insert(ip.items.in_inventory, {
            inventory = defines.inventory.chest,
            stack = slot,
            count = subtract,
          })
          slot = slot + 1
          count = count - subtract
        end
        table.insert(insert_plan, ip)
      end
    end
  end

  return insert_plan
end

Buildings.set_filters = function (building, filters)
  if not building.inventory then return end

  local bar = nil

  for slot = 1, #building.inventory do
    local filter = filters[slot]
    building.inventory.set_filter(slot, filter)
    if filter == nil and bar == nil then
      bar = slot
    end
  end

  if bar == nil then
    building.inventory.set_bar()
  else
    building.inventory.set_bar(bar)
  end

  Buildings.yeet_squatters(building.inventory)
end

local function filter_rejects(filter, stack)
  if filter == nil then return end

  if filter.name ~= stack.name then return true end
  if filter.quality ~= stack.quality.name then return true end
end

Buildings.yeet_squatters = function (inventory)
  local bar = inventory.get_bar()

  for slot = 1, #inventory do
    local stack = inventory[slot]
    if stack.valid_for_read then
      if slot >= bar or filter_rejects(inventory.get_filter(slot), stack) then
        inventory.entity_owner.surface.spill_item_stack{
          stack = stack,
          position = inventory.entity_owner.position,
          force = inventory.entity_owner.force,
          allow_belts = false,
          drop_full_stack = true,
        }
        stack.clear()
      end
    end
  end
end

Buildings.set_insert_plan = function(building, insert_plan)
  if not building.inventory then return end

  -- cancels any deliveries
  if building.entity.item_request_proxy then
    building.entity.item_request_proxy.destroy()
  end

  -- log(serpent.block(insert_plan))
  building.entity.surface.create_entity{
    name = "item-request-proxy",
    force = building.entity.force,
    position = building.entity.position,
    target = building.entity,
    modules = insert_plan,
  }
end

script.on_event(mod_prefix .. "build", function(event)
  if event.selected_prototype and mod.container_names_map[event.selected_prototype.name] then
    local playerdata = storage.playerdata[event.player_index]
    local selected = playerdata.player.selected

    if selected and mod.container_names_map[get_entity_name(selected)] then
      if mod.player_holding_hut(playerdata.player) then
        local building = storage.buildings[selected.unit_number]
        Buildings.set_factory_index(building, playerdata.held_factory_index)
      end
    end
  end
end)

-- prevents the triggers from updating the status
Buildings.set_status = function(building, status)
  if building.factory_index == nil then return end

  building.line_3.text = status
  building.line_4.text = ""
end

Buildings.turn_eei_on = function(building)
  local factory = storage.factories[building.factory_index]
  local watts = factory.export.power * prefix_to_multiplier(factory.export.power_prefix)
  building.children.eei.electric_buffer_size = math.max(1, watts) -- buffer for 1 second
  building.children.eei.power_usage = watts / 60
end

Buildings.turn_eei_off = function(building)
  building.children.eei.power_usage = 0
end

return Buildings
