script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "k2-imersite-created" then return end
  local entity = event.source_entity --[[@as LuaEntity]]

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
  if not zone then return end
  if not zone.is_homeworld then return end

  local imersite_veins = entity.surface.find_entities_filtered{
    name = entity.name,
    position = entity.position,
    radius = 30, -- random number
  }

  -- is there more than just me?
  if #imersite_veins > 1 then
    entity.destroy() -- bye
  end
end)
