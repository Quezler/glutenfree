local TickHandler = {}

function TickHandler.invalidate_struct_ids()
  storage.struct_ids = {}

  for struct_id, struct in pairs(storage.structs) do
    storage.struct_ids[#storage.struct_ids+1] = struct_id
  end
end

function TickHandler.get_random_struct_id()
  return storage.struct_ids[math.random(1, #storage.struct_ids)]
end

local next_quality = {} -- prototype_name to prototype map
for _, quality_prototype in pairs(prototypes.quality) do
  next_quality[quality_prototype.name] = quality_prototype.next
end

function TickHandler.update_struct(struct)
  local control_behavior = struct.entities.decider.get_control_behavior()
  local green_network = struct.entities.decider.get_circuit_network(defines.wire_connector_id.combinator_output_green)

  for _, signal_and_count in ipairs(green_network.signals or {}) do
    local payout = math.floor(signal_and_count.count / storage.items_per_next_quality)
    if payout == 0 then goto continue end

    local next_quality = next_quality[signal_and_count.signal.quality or "normal"]
    if next_quality == nil then goto continue end
    if struct.force.is_quality_unlocked(next_quality) == false then goto continue end -- todo: cache
    -- game.print(next_quality)
    -- game.print(serpent.line(struct.force.is_quality_unlocked(next_quality)))

    local inventory = struct.entities.upcycler.get_inventory(defines.inventory.furnace_result)
    local inserted = inventory.insert({name=signal_and_count.signal.name, count=payout, quality=next_quality})
    if inserted == 0 then goto continue end

    control_behavior.add_output({
      signal = {
        type = "item",
        name = signal_and_count.signal.name,
        quality = signal_and_count.signal.quality,
      },
      constant = -(payout * storage.items_per_next_quality),
      copy_count_from_input = false,
    })

    ::continue::
  end
end

function TickHandler.on_tick(event)
  if #storage.struct_ids > 0 then
    local struct_id = TickHandler.get_random_struct_id()
    local struct = storage.structs[struct_id]
    TickHandler.update_struct(struct)
  end
end

return TickHandler
