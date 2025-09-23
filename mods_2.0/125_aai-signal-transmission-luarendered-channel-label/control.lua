local mod = {}

script.on_init(function()
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {"aai-signal-sender", "aai-signal-receiver"}})) do
      on_created_entity({entity = entity})
    end
  end
end)

script.on_configuration_changed(function()
  storage.deathrattles = nil

  for unit_number, struct in pairs(storage.structs) do
    if not struct.entity.valid then
      storage.structs[unit_number] = nil
    end
  end
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination
  storage.structs[entity.unit_number] = {
    entity = entity,
    text = nil, -- luarendering
  }

  local channel = remote.call("aai-signal-transmission", "get_channel_by_unit_number", {unit_number = entity.unit_number})
  mod.update_text(entity.unit_number, channel)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, {
    {filter = "name", name = "aai-signal-sender"},
    {filter = "name", name = "aai-signal-receiver"},
  })
end

script.on_event(prototypes.custom_event["aai-signal-transmission-subscribed"], function(event)
  mod.update_text(event.entity.unit_number, event.channel)
end)

mod.update_text = function(unit_number, channel)
  local struct = storage.structs[unit_number]
  if not struct then return end

  -- if struct.text then text.destroy() end
  if struct.text == nil then
    local entity = struct.entity
    struct.text = rendering.draw_text{
      text = channel,
      color = {1, 1, 1},
      surface = entity.surface,
      position = entity.position,
      target = {entity = entity, offset = {0, -1.5}},
      alignment = "center",
      use_rich_text = true,
    }
  else
    struct.text.text = channel
  end
end
