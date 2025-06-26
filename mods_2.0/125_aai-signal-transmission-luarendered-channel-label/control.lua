local Util = require("__aai-signal-transmission__.scripts.util")

local mod = {}

mod.get_as_blueprint_entity = function(entity)
  local inventory = game.create_inventory(1)
  local stack = inventory[1]

  stack.set_stack({name = "blueprint"})
  stack.create_blueprint{
    surface = entity.surface,
    force = entity.force,
    area = entity.bounding_box,
  }

  local blueprint_entities = stack.get_blueprint_entities() or {}
  inventory.destroy()

  for _, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == entity.name then
      return blueprint_entity
    end
  end

  error(serpent.block({'get_as_blueprint_entity failed:', entity, blueprint_entities}))
end

mod.update_text_by_entity = function(entity)
  local channel = "Default"
  local blueprint_entity = mod.get_as_blueprint_entity(entity)
  game.print(serpent.line(blueprint_entity))
  if blueprint_entity.tags and blueprint_entity.tags.channel then
    channel = blueprint_entity.tags.channel --[[@as string]]
  end
  mod.update_text(entity.unit_number, channel)
end

local function on_created_entity(event)
  local entity = event.entity or event.destination
  storage.structs[entity.unit_number] = {
    unit_number = entity.unit_number,
    entity = entity,
    opened = false,
    text = nil,
  }

  mod.update_text_by_entity(entity)
end

script.on_init(function(event)
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({name = {"aai-signal-sender", "aai-signal-receiver"}})) do
      on_created_entity({entity = entity})
    end
  end
end)

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    {filter = "name", name = "aai-signal-sender"},
    {filter = "name", name = "aai-signal-receiver"},
  })
end

mod.update_text = function(unit_number, channel)
  local struct = storage.structs[unit_number]
  if not struct then return end

  if Util.string_trim(channel) == "" then channel = "Default" end

  struct.opened = true
  -- if struct.text then text.destroy() end
  if struct.text == nil then
    local entity = struct.entity
    struct.text = rendering.draw_text{
      text = channel,
      color = {1, 1, 1},
      surface = entity.surface,
      position = entity.position,
      target = entity,
      target_offset = {0, -1.5},
      alignment = "center",
      use_rich_text = true,
    }
  else
    struct.text.text = channel
  end
end

remote.add_interface("aai-signal-transmission-luarendered-channel-label", {update_text = mod.update_text})

script.on_event(defines.events.on_entity_settings_pasted, function (event)
  if event.destination.name == "aai-signal-sender" or event.destination.name == "aai-signal-receiver" then
    mod.update_text_by_entity(event.destination)
  end
end)
