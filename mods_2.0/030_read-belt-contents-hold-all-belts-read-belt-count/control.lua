local frame_name = "rbchabrbc-frame"

local Handler = {}

local function entity_is_transport_belt(entity)
  return entity.type == "transport-belt" or (entity.type == "entity-ghost" and entity.ghost_type == "transport-belt")
end

script.on_init(function(event)
  storage.players_in_belt_gui = {}
end)

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity_is_transport_belt(entity) then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

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

    flow1.add{
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

    flow2.add{
      type = "label",
      caption = {"gui-control-behavior-modes-guis.control-signal"},
      enabled = enabled,
    }

    flow2.add{
      type = "choose-elem-button",
      elem_type = "signal",
      signal = {type = "virtual", name = "signal-B"},
      enabled = enabled,
    }

    storage.players_in_belt_gui[player.index] = {player = player, entity = entity}
    script.on_event(defines.events.on_tick, Handler.on_tick)
  end
end)

function Handler.on_tick(event)
  for player_index, player_and_entity in pairs(storage.players_in_belt_gui) do
    if player_and_entity.player.valid == false or player_and_entity.entity.valid == false or player_and_entity.player.connected == false then
      storage.players_in_belt_gui[player_index] = nil
    else
      local cb = player_and_entity.entity.get_or_create_control_behavior() --[[@as LuaTransportBeltControlBehavior]]
      game.print(cb.read_contents and cb.read_contents_mode == defines.control_behavior.transport_belt.content_read_mode.entire_belt_hold)
    end
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
  if belt == nil then entity.destroy() end
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
