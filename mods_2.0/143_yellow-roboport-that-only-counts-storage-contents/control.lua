local defines_control_behavior_roboport_read_items_mode_none = defines.control_behavior.roboport.read_items_mode.none

local mod = {}

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination
  entity.backer_name = nil

  local cb = entity.get_or_create_control_behavior() --[[@as LuaRoboportControlBehavior]]
  cb.read_items_mode = defines_control_behavior_roboport_read_items_mode_none

  storage.structs[entity.unit_number] = {
    entity = entity,
    cb = cb,
  }
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
    {filter = "name", name = "storage-roboport"},
  })
end

script.on_nth_tick(60, function()
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      struct.cb.read_items_mode = defines_control_behavior_roboport_read_items_mode_none
    end
  end
end)
