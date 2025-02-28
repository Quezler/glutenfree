require("shared")
local mod = {}

script.on_init(function()
  storage.deathrattles = {}
  storage.structs = {}

  for _, surface in pairs(game.surfaces) do
    for _, entity in pairs(surface.find_entities_filtered({type = "lab"})) do
      mod.on_created_entity({entity = entity})
    end
  end
end)

function mod.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,

    proxy = nil,
    proxies = {},
  })

  game.print("new lab registered: " .. tostring(entity))

  local cb = entity.surface.create_entity{
    name = mod_prefix .. entity.name .. "-control-behavior",
    force = entity.force,
    position = {entity.position.x, entity.position.y + 1},
  }
  cb.destructible = false
  cb.proxy_target_entity = entity
  cb.proxy_target_inventory = defines.inventory.lab_input
  struct.proxy = cb
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
    {filter = "type", type = "lab"},
  })
end

local gui_frame_name = mod_prefix .. "frame"

function mod.open_gui(entity, player)
  local frame = player.gui.relative[gui_frame_name]
  if frame then frame.destroy() end

  frame = player.gui.relative.add{
    type = "frame",
    name = gui_frame_name,
    caption = {"gui-control-behavior.circuit-connection"},
    anchor = {
      gui = defines.relative_gui_type.lab_gui,
      position = defines.relative_gui_position.right,
    },
  }

  local inner = frame.add{
    type = "frame",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  inner.add{
    type = "radiobutton",
    caption = "Read contents",
    state = true,
  }
  inner.add{
    type = "radiobutton",
    caption = "Read contents (surface)",
    state = false,
  }
  inner.add{
    type = "radiobutton",
    caption = "Read contents (surfaces)",
    state = false,
  }
end

local is_lab_control_behavior = {}
for _, prototype in pairs(prototypes.get_entity_filtered{{filter="type", type="lab"}}) do
  local proxy = prototypes.entity[mod_prefix .. prototype.name .. "-control-behavior"]
  if proxy then
    is_lab_control_behavior[proxy.name] = true
  end
end
log(serpent.block(is_lab_control_behavior))

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity

  if entity then
    if entity.type == "lab" then
      local player = game.get_player(event.player_index) --[[@as LuaEntity]]
      mod.open_gui(entity, player)
    elseif is_lab_control_behavior[entity.name] then
      local lab = entity.surface.find_entities_filtered{
        type = "lab",
        position = entity.position,
        limit = 1,
      }[1]
      if lab then
        local player = game.get_player(event.player_index) --[[@as LuaEntity]]
        player.opened = lab
      end
    end
  end
end)
