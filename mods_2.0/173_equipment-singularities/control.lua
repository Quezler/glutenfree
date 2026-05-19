require("shared")

local mod = {}
local mod_data = prototypes.mod_data[mod_name].data --[[@as EquipmentSingularitiesModData]]

local ingredient_amount = settings.startup[mod_prefix .. "amount"].value --[[@as number]]

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

script.on_configuration_changed(function()
  --
end)

function new_struct(table, struct)
  table[struct.index] = struct
  return struct
end

mod.on_created_entity_filters = {
  {filter = "name", name = mod_prefix .. "chest"},
}

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    index = entity.unit_number,
    entity = entity,
  })

  -- /c game.player.selected.get_inventory(defines.inventory.chest)[1].count = 100000
  struct.inventory = entity.get_inventory(defines.inventory.chest)
  struct.stack = struct.inventory[1]

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = struct.id}
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

script.on_nth_tick(60, function()
  for _, struct in pairs(storage.structs) do
    if struct.entity.valid then
      if struct.stack.valid_for_read then
        if struct.stack.count >= ingredient_amount then
          if mod_data.items[struct.stack.name] then
            struct.stack.set_stack({name = mod_prefix .. struct.stack.name})
            struct.entity.force.print(string.format("1 x %s %s", struct.stack.name, struct.entity.gps_tag))
          end
        end
      end
    else
      storage.structs[struct.index] = nil
    end
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      --
    end
  end
end)
