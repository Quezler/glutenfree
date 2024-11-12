local frame_name = "rbchabrbc-frame"
local gui_checkbox_name = "rbchabrbc-checkbox"

local Handler = {}

require("script.helpers")

script.on_init(function(event)
  storage.players_in_belt_gui = {}

  storage.playerdata = {}

  storage.index = 0
  storage.structs = {}
  storage.unit_number_to_struct_id = {}

  storage.deathrattles = {}
end)

local function reset_read_belt_count_gui(player)
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
  local checked = false

  if player_is_in_belt_gui(player) then
    local struct_id = storage.unit_number_to_struct_id[player.opened.unit_number]
    local struct = storage.structs[struct_id]

    enabled = is_belt_read_holding_all_belts(player.opened)

    if struct then
      checked = true
    end
  end

  playerdata.gui_checkbox = flow1.add{
    type = "checkbox",
    name = gui_checkbox_name,
    style = "caption_checkbox",
    caption = {"gui-control-behavior-modes.read-belt-count"},
    state = checked,
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
    enabled = checked,
  }

  storage.playerdata[player.index] = playerdata
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity_is_transport_belt(entity) then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

    reset_read_belt_count_gui(player)

    storage.players_in_belt_gui[player.index] = player
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

local function on_tick_player(player)
  if player_is_in_belt_gui(player) == false then return end
  if player.connected == false then return end

  local opened = player.opened
  local enabled = is_belt_read_holding_all_belts(opened)

  local struct_id = storage.unit_number_to_struct_id[opened.unit_number]
  local struct = storage.structs[struct_id]

  if enabled then
    local playerdata = storage.playerdata[player.index]
    playerdata.gui_checkbox.enabled = true
    playerdata.gui_label   .enabled = true
    playerdata.gui_signal  .enabled = playerdata.gui_checkbox.state
  else
    if struct then
      Handler.delete_struct(struct)
    end
    reset_read_belt_count_gui(player)
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

  -- assert(storage.structs[belt.unit_number] == nil)
  storage.index = storage.index + 1
  storage.structs[storage.index] = {
    id = storage.index,

    belt = nil,
    combinator = entity,
  }

  attach_belt_to_struct(belt, storage.structs[storage.index])
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
    local unit_number = assert(event.useful_id)
    local struct_id = assert(storage.unit_number_to_struct_id[unit_number])

    local struct = storage.structs[struct_id]
    if struct then
      -- in case the entity becomes a ghost or get upgraded, try to adopt that new entity.
      local combinator = struct.combinator
      local belt = Handler.get_belt_at(combinator.surface, combinator.position)
      if belt then
        attach_belt_to_struct(belt, struct)
      else
        Handler.delete_struct(struct)
      end
    end

    storage.unit_number_to_struct_id[unit_number] = nil
  end
end)

function Handler.delete_struct(struct)
  struct.combinator.destroy()
  storage.structs[struct.id] = nil

  -- if struct.belt.valid then storage.unit_number_to_struct_id[struct.belt.unit_number] = nil end
end

script.on_nth_tick(600, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if is_belt_read_holding_all_belts(struct.belt) == false then
      game.print("nth 60 delete")
      Handler.delete_struct(struct)
    end
  end
end)

script.on_event(defines.events.on_gui_checked_state_changed, function(event)
  if event.element.name == gui_checkbox_name then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    if player_is_in_belt_gui(player) then
      local opened = player.opened --[[@as LuaEntity]]
      local struct_id = storage.unit_number_to_struct_id[opened.unit_number]
      local struct = storage.structs[struct_id]

      if event.element.state then
        assert(struct == nil, "found struct but expected nil")
        opened.surface.create_entity{
          name = "read-belt-contents-hold-all-belts-read-belt-count",
          force = opened.force,
          position = opened.position,
          raise_built = true,
        }

        local playerdata = storage.playerdata[player.index]
        playerdata.gui_signal.enabled = true
      else
        assert(struct ~= nil, "found nil but expected struct")
        Handler.delete_struct(struct)

        local playerdata = storage.playerdata[player.index]
        playerdata.gui_signal.enabled = false
        playerdata.gui_signal.elem_value = {type = "virtual", name = "signal-B"}
      end

    end
  end
end)
