---@class storage
  ---@field nodes table<number, NodeStruct>
  ---@field nodes_index number?

---@class NodeStruct
  ---@field index number
  ---@field type "item"|"fluid"
  ---@field entity_prototype LuaEntityPrototype
  ---@field name string
  ---@field amount number
  ---@field original_amount? number
  ---@field item LuaItem

local mod = {}
mod.data = prototypes.mod_data["minable-resources"].data

---@param node NodeStruct
function mod.update_description(node)
  node.item.item_stack.health = node.amount / node.original_amount
  if node.type == "item" then
    local amount_str = tostring(node.amount):reverse():gsub("(%d%d%d)", "%1 "):reverse():gsub("^ ", "")
    node.item.custom_description = {"minable-resources.description", {"description.amount"}, amount_str}
  else
    local amount_str = string.format("%d", 100 * node.amount / node.entity_prototype.normal_resource_amount)
    node.item.custom_description = {"minable-resources.description", {"description.yield"}, {"format-percent", amount_str}}
  end
end

---@param node NodeStruct
function mod.add_struct(node)
  storage.nodes[node.index] = node

  node.original_amount = node.amount

  if not node.item.item_stack.is_module then
    mod.update_description(node)
  end

  return node
end

script.on_init(function()
  storage.nodes = {}
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
  local resource = event.entity

  local item_name = mod.data.resource_to_node_map[resource.name]
  if not item_name then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if not player.can_insert(item_name) then return end -- inventory full

  local inventory = player.get_inventory(defines.inventory.character_main) --[[@as LuaInventory]]
  local stack, _ = inventory.find_empty_stack() --[[@as LuaItemStack]]
  stack.set_stack(item_name)

  mod.add_struct({
    index = stack.item_number,
    type = resource.prototype.mineable_properties.products[1].type,
    entity_prototype = resource.prototype,
    name = resource.name,
    amount = resource.amount,
    item = assert(stack.item),
  })

  player.create_local_flying_text{
    text = string.format("+1 [item=%s] (%d)", item_name, inventory.get_item_count(item_name)),
    position = resource.position,
  }
  resource.destroy()
end)

---@param node NodeStruct
function mod.remove_struct(node)
  if node.index == storage.nodes_index then -- invalid key to 'next'
    storage.nodes_index = next(storage.nodes, storage.nodes_index)
  end
  storage.nodes[node.index] = nil
end

---@param node NodeStruct
---@param item LuaItem
function mod.struct_update_item(node, item)
  mod.remove_struct(node)
  node.item = item
  node.index = node.item.item_number
  storage.nodes[node.index] = node
  mod.update_description(node)
end

local type_has_module_slots = {
  ["furnace"] = true,
  ["assembling-machine"] = true,
}

---@param node NodeStruct
function mod.tick_node(node)
  -- if node.item.valid == false then
  --   storage.nodes[node.index] = nil
  --   return
  -- end

  local owner = node.item.owner_location
  if owner and owner.entity and type_has_module_slots[owner.entity.type] then
    local inserted = owner.entity.insert({name = node.name, count = node.amount})
    if inserted > 0 then
      node.amount = node.amount - inserted
      if node.amount == 0 then
        node.item.item_stack.clear()
        mod.remove_struct(node)
      else
        mod.update_description(node)
      end
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  storage.nodes_index, current_node = next(storage.nodes, storage.nodes_index)
  if current_node then mod.tick_node(current_node) end
end)

-- script.on_event(defines.events.on_built_entity, function(event)
--   local inventory = event.entity.get_inventory(defines.inventory.crafter_modules)
--   if inventory and #inventory >= 2 then
--     local stack1 = inventory[1]
--     stack1.set_stack("iron-ore-node-module")
--     stack1.spoil()
--     mod.add_struct({
--       index = stack1.item_number,
--       type = "item",
--       entity_prototype = prototypes.entity["iron-ore"],
--       name = "iron-ore",
--       amount = 123,
--       item = assert(stack1.item),
--     })

--     local stack2 = inventory[2]
--     stack2.set_stack("coal-node-module")
--     stack2.spoil()
--     mod.add_struct({
--       index = stack2.item_number,
--       type = "item",
--       entity_prototype = prototypes.entity["coal"],
--       name = "coal",
--       amount = 321,
--       item = assert(stack2.item),
--     })
--   end
-- end)

script.on_event("mr-drop-cursor", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read then
    local node_name = player.cursor_stack.name
    if mod.data.node_item_name_set[node_name] then
      local node = storage.nodes[player.cursor_stack.item_number]
      if not node then
        player.cursor_stack.clear()
        log(player.name .. " tried dropping an unknown node.")
        return
      end

      if not player.selected then return end

      local inventory = player.selected.get_module_inventory()
      if not inventory then return end

      local module_name = node_name .. "-module"
      if inventory.can_insert({name = module_name}) then
        player.cursor_stack.clear()
        player.create_local_flying_text{
          text = string.format("-1 [item=%s] (%d)", node_name, player.get_inventory(defines.inventory.character_main).get_item_count(node_name)),
          position =  player.selected.position,
        }
        inventory.insert({name = module_name})
        local stack = inventory.find_item_stack({name = module_name}) --[[@as LuaItemStack]]
        stack.spoil()
        mod.struct_update_item(node, stack.item)
      end
    end
  end
end)
