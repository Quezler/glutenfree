local frame_name = "rbchabrbc-frame"

local Handler = {}

local function entity_is_transport_belt(entity)
  return entity.type == "transport-belt" or (entity.type == "entity-ghost" and entity.ghost_type == "transport-belt")
end

script.on_init(function(event)
  storage.players_in_belt_gui = {}

  storage.playerdata = {}
  storage.structs = {}

  storage.deathrattles = {}
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity_is_transport_belt(entity) then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local playerdata = {}

    local frame = player.gui.relative[frame_name]
    if frame then frame.destroy() end

    frame = player.gui.relative.add{
      type = "frame",
      name = frame_name,
      anchor = {
        gui = defines.relative_gui_type.transport_belt_gui,
        position = defines.relative_gui_position.right,
      },
    }
    frame.style.top_padding = 8

    local inner = frame.add{
      type = "frame",
      style = "inside_shallow_frame_with_padding",
      direction = "vertical",
    }

    local flow1 = inner.add{
      type = "flow",
    }

    local enabled = false

    playerdata.gui_checkbox = flow1.add{
      type = "checkbox",
      style = "caption_checkbox",
      caption = {"gui-control-behavior-modes.read-belt-count"},
      state = enabled,
      enabled = enabled,
    }

    local flow2 = inner.add{
      type = "flow",
      style = "player_input_horizontal_flow"
    }
    flow2.style.top_margin = 4

    playerdata.gui_label = flow2.add{
      type = "label",
      caption = {"gui-control-behavior-modes-guis.control-signal"},
      enabled = enabled,
    }

    playerdata.gui_signal = flow2.add{
      type = "choose-elem-button",
      elem_type = "signal",
      signal = {type = "virtual", name = "signal-B"},
      enabled = enabled,
    }

    storage.playerdata[player.index] = playerdata

    storage.players_in_belt_gui[player.index] = player
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

local function is_belt_read_holding_all_belts(entity) -- boolean
  local red = entity.get_circuit_network(defines.wire_connector_id.circuit_red)
  local green = entity.get_circuit_network(defines.wire_connector_id.circuit_green)
  if (red == nil and green == nil) then return false end

  local cb = entity.get_or_create_control_behavior() --[[@as LuaTransportBeltControlBehavior]]
  local enabled = cb.read_contents and cb.read_contents_mode == defines.control_behavior.transport_belt.content_read_mode.entire_belt_hold

  return enabled
end

local function on_tick_player(player)
  local opened = player.opened
  if opened == nil then return end

  if player.opened_gui_type ~= defines.gui_type.entity then return end
  if entity_is_transport_belt(player.opened) == false then return end
  if player.connected == false then return end

  local enabled = is_belt_read_holding_all_belts(opened)

  local playerdata = storage.playerdata[player.index]
  playerdata.gui_checkbox.enabled = enabled
  playerdata.gui_label   .enabled = enabled
  playerdata.gui_signal  .enabled = enabled

  local struct = storage.structs[opened.unit_number]
  if struct == nil and enabled == true then
    opened.surface.create_entity{
      name = "read-belt-contents-hold-all-belts-read-belt-count",
      force = opened.force,
      position = opened.position,
      raise_built = true,
    }
  elseif struct ~= nil and enabled == false then
    struct.combinator.destroy()
    storage.structs[opened.unit_number] = nil
  end

  return true
end

function Handler.on_tick(event)
  for player_index, player in pairs(storage.players_in_belt_gui) do
    if not on_tick_player(player) then storage.players_in_belt_gui[player_index] = nil end
  end

  if next(storage.players_in_belt_gui) == nil then
    script.on_event(defines.events.on_tick, nil)
  end
end

script.on_load(function()
  if next(storage.players_in_belt_gui) ~= nil then
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

function Handler.get_belt_at(surface, position)
  local belts = surface.find_entities_filtered{
    position = position,
    type = "transport-belt",
    limit = 1,
  }
  if belts[1] then return belts[1] end

  local ghosts = surface.find_entities_filtered{
    position = position,
    ghost_type = "transport-belt",
    limit = 1,
  }
  if ghosts[1] then return ghosts[1] end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local belt = Handler.get_belt_at(entity.surface, entity.position)
  if belt == nil then
    return entity.destroy()
  end

  -- this entity is allowed to be built under a ghost, and to avoid "missing construction materials" we'll just always revive it.
  if entity.type == "entity-ghost" then
    return entity.revive{raise_revive = true}
  end

  entity.destructible = false

  -- sanity check
  local combinators = entity.surface.find_entities_filtered{
    position = entity.position,
    name = "read-belt-contents-hold-all-belts-read-belt-count",
  }
  assert(#combinators == 1, "expected 1 combinator but found " .. #combinators)

  assert(storage.structs[belt.unit_number] == nil)
  storage.structs[belt.unit_number] = {
    belt = belt,
    combinator = entity,
  }

  storage.deathrattles[script.register_on_object_destroyed(belt)] = {}
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
    -- {filter =       "type", type = "transport-belt"},
    -- {filter = "ghost_type", type = "transport-belt"},
    {filter =       "name", name = "read-belt-contents-hold-all-belts-read-belt-count"},
    {filter = "ghost_name", name = "read-belt-contents-hold-all-belts-read-belt-count"},
  })
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct_id = assert(event.useful_id)
    local struct = assert(storage.structs[struct_id])

    -- in case the entity becomes a ghost or get upgraded, try to adopt that new entity.
    local combinator = struct.combinator
    local belt = Handler.get_belt_at(combinator.surface, combinator.position)
    if belt then
      struct.belt = belt
      storage.deathrattles[script.register_on_object_destroyed(belt)] = {}
      storage.structs[belt.unit_number] = struct
    else
      combinator.destroy()
    end

    storage.structs[struct_id] = nil
  end
end)
