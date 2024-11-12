function entity_is_transport_belt(entity)
  return entity.type == "transport-belt" or (entity.type == "entity-ghost" and entity.ghost_type == "transport-belt")
end

function player_is_in_belt_gui(player)
  local opened = player.opened
  if opened == nil then return false end

  if player.opened_gui_type ~= defines.gui_type.entity then return false end
  if entity_is_transport_belt(player.opened) == false then return false end

  return true
end

function is_belt_read_holding_all_belts(entity) -- boolean
  local red = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  local green = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
  if (red == nil and green == nil) then return false end

  local cb = entity.get_or_create_control_behavior() --[[@as LuaTransportBeltControlBehavior]]
  local enabled = cb.read_contents and cb.read_contents_mode == defines.control_behavior.transport_belt.content_read_mode.entire_belt_hold

  return enabled
end

function attach_belt_to_struct(belt, struct)
  struct.belt = belt

  storage.unit_number_to_struct_id[belt.unit_number] = struct.id
  storage.deathrattles[script.register_on_object_destroyed(belt)] = {}
end
