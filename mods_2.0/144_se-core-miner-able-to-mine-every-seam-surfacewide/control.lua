local mod = {}

require("namespace")
require("scripts.surfacedata")(mod)

script.on_init(function()
  storage.surfacedata = {}
  mod.refresh_surfacedata()

  storage.deathrattles = {}

  mod.register_events()

  -- in on_init the beacon-interface mod is not listening for build events yet.
  script.on_event(defines.events.on_tick, function(event)
    for _, surface in pairs(game.surfaces) do
      for _, core_miner in ipairs(surface.find_entities_filtered{name = "se-core-miner-drill"}) do
        mod.on_created_entity({entity = core_miner, multiplier_override = 1})
      end
    end
    script.on_event(defines.events.on_tick, nil)
  end)
end)

script.on_configuration_changed(function()
  mod.refresh_surfacedata()
end)

script.on_load(function()
  mod.register_events()
end)

mod.register_events = function()
  script.on_event(remote.call("se-core-miner-efficiency-updated-event", "on_efficiency_updated"), function(event)
    local surfacedata = storage.surfacedata[event.surface_index]
    for _, struct in pairs(surfacedata.structs) do
      if struct.entity.valid then
        mod.update_amount(surfacedata, struct)
      end
    end

    local zone = remote.call("space-exploration", "get_zone_from_zone_index", {zone_index = event.zone_index})
    if zone.core_seam_resources == nil then return end -- 50x50 worlds?

    for _, resource_set in pairs(zone.core_seam_resources) do
      local resource = resource_set.resource

      for _, render_object in ipairs(rendering.get_all_objects("space-exploration")) do
        if render_object.type == "text" and render_object.target.entity == resource then
          render_object.destroy() -- if anything it'd be confusing to show for this mod
        end
      end
    end
  end)
end

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination
  local surfacedata = storage.surfacedata[entity.surface_index]

  local beacon = entity.surface.create_entity{
    name = mod_prefix .. "beacon-interface",
    force = entity.force,
    position = entity.position,
    raise_built = true,
  }
  beacon.destructible = false

  local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
  mod.cache_zone_on_surfacedata(zone, surfacedata)

  -- newly placed drills get a muliplier of 1 if there's still allication left, otherwise they just get 0
  local desired_multiplier = 1
  if event.tags and event.tags[mod_prefix .. "multiplier"] then
    desired_multiplier = event.tags[mod_prefix .. "multiplier"]
  end
  local multiplier = event.multiplier_override or math.min(desired_multiplier, surfacedata.total_seams - surfacedata.total_miners)
  assert(multiplier >= 0)

  surfacedata.structs[entity.unit_number] = {
    entity = entity,

    multiplier = 0,
    beacon = beacon,
  }

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {surface_index = entity.surface.index, unit_number = entity.unit_number}
  mod.set_multiplier(surfacedata, surfacedata.structs[entity.unit_number], multiplier)
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
    {filter = "name", name = "se-core-miner-drill"},
  })
end

mod.set_multiplier = function(surfacedata, struct, multiplier)
  surfacedata.total_miners = surfacedata.total_miners - struct.multiplier
  struct.multiplier = multiplier
  surfacedata.total_miners = surfacedata.total_miners + struct.multiplier

  remote.call("beacon-interface", "set_effects", struct.beacon.unit_number, {
    speed = 0,
    productivity = 0,
    consumption = (100 * multiplier) - 100,
    pollution = 0,
    quality = 0,
  })

  mod.update_amount(surfacedata, struct)
end

mod.get_mining_target = function(entity)
  return entity.mining_target or entity.surface.find_entities_filtered{position = entity.position, radius = 0, type = "resource"}[1]
end

mod.update_amount = function(surfacedata, struct)
  local fragment_mining_time = mod.get_core_fragment_mining_time(surfacedata.fragment_name)
  local fragments_per_second = mod.get_surface_output(surfacedata, {mining_drill_productivity_bonus = 0}, struct.multiplier)
  mod.get_mining_target(struct.entity).amount = math.max(1, 10000 * fragment_mining_time * fragments_per_second)
end

--- @return number
mod.get_core_seams_for_radius = function(radius)
  return 5 + math.floor(95 * radius / 10000)
end

--- @return string?
mod.get_core_fragment_name = function(zone)
  if not (zone.type == "planet" or zone.type == "moon") then return end -- Zone.is_solid(zone)
  if zone.fragment_name then return zone.fragment_name end
  return "se-core-fragment-" .. zone.primary_resource
end

--- @return number
mod.get_core_fragment_mining_time = function(fragment_name)
  return prototypes.entity[fragment_name].mineable_properties.mining_time
end

--- @return number
mod.get_core_fragments_per_second = function(fragment_name, zone_radius, mining_productivity, core_miners)
  if core_miners == 0 then return 0 end -- or this function returns nan
  return ((100 / mod.get_core_fragment_mining_time(fragment_name)) * ((zone_radius + 5000) / 5000) * mining_productivity * core_miners) / math.sqrt(core_miners)
end

local gui_frame_name = "se-core-miner-fragments-frame"
local gui_inner_name = "se-core-miner-fragments-inner"
local gui_slider_name = "se-core-miner-fragments-slider"

mod.open_gui = function(player, entity)
  local surfacedata = storage.surfacedata[entity.surface.index]
  local struct = surfacedata.structs[entity.unit_number]

  local frame = player.gui.relative[gui_frame_name]
  if frame then frame.destroy() end

  local fragment_name = mod.get_mining_target(entity).name

  frame = player.gui.relative.add{
    type = "frame",
    name = gui_frame_name,
    style = "frame_with_even_paddings",
    anchor = {
      gui = defines.relative_gui_type.mining_drill_gui,
      position = defines.relative_gui_position.bottom,
      name = "se-core-miner-drill",
    },
    tags = {
      surface_index = entity.surface_index,
      unit_number = entity.unit_number,
    }
  }

  local inner = frame.add{
    type = "frame",
    name = gui_inner_name,
    style = "inside_shallow_frame_with_padding_and_vertical_spacing",
    direction = "horizontal",
  }
  inner.style.left_padding = 6
  inner.style.right_padding = 6

  local slider = inner.add{
    type = "slider",
    name = gui_slider_name,
    style = "notched_slider",
    minimum_value = 0,
    value = struct.multiplier,
    maximum_value = surfacedata.total_seams,
  }
  slider.style.horizontally_stretchable = true

  local texts = inner.add{
    type = "flow",
    name = "texts",
    direction = "vertical",
  }
  texts.style.vertical_spacing = 0
  texts.style.top_margin = -10
  texts.style.bottom_margin = -10

  local line_1 = texts.add{
    type = "label",
    name = "line-1",
    caption = string.format("[entity=se-core-miner-drill] %03d/%03d", struct.multiplier, surfacedata.total_seams)
  }
  line_1.style.minimal_width = 78

  local line_2 = texts.add{
    type = "label",
    name = "line-2",
    caption = string.format("[item=%s] %06.2f/s", fragment_name, mod.get_surface_output(surfacedata, entity.force, struct.multiplier))
  }
  line_2.style.minimal_width = 78
end

mod.get_surface_output = function(surfacedata, force, total_drills)
  local mining_productivity = 1 + force.mining_drill_productivity_bonus

  if script.active_mods["se-core-miner-no-diminishing-returns"] then
    return mod.get_core_fragments_per_second(surfacedata.fragment_name, surfacedata.zone_radius, mining_productivity, 1) * total_drills
  else
    return mod.get_core_fragments_per_second(surfacedata.fragment_name, surfacedata.zone_radius, mining_productivity, total_drills)
  end
end

mod.cache_zone_on_surfacedata = function(zone, surfacedata)
  surfacedata.fragment_name = mod.get_core_fragment_name(zone)
  surfacedata.zone_radius = zone.radius
  surfacedata.total_seams = mod.get_core_seams_for_radius(zone.radius)
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == "se-core-miner-drill" then
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
    if not zone then return end -- how did you even place this outside a zone?

    -- cache some zone information on the surfacedata object
    local surfacedata = storage.surfacedata[entity.surface.index]
    mod.cache_zone_on_surfacedata(zone, surfacedata)

    mod.open_gui(game.get_player(event.player_index), entity)
  end
end)

-- commands.add_command("se-core-miner-set-output", nil, function(command)
--   local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
--   local entity = player.selected

--   if entity and entity.name == "se-core-miner-drill" then
--     local fragment_name = entity.mining_target.name
--     local fragment_mining_time = mod.get_core_fragment_mining_time(fragment_name)
--     entity.mining_target.amount = 10000 * fragment_mining_time * (tonumber(command.parameter) or 1) -- 1/s
--   end
-- end)

script.on_event(defines.events.on_gui_value_changed, function(event)
  local element = event.element

  if element.name == gui_slider_name then
    local root = assert(element.parent.parent)
    assert(root.name == gui_frame_name)

    local surfacedata = storage.surfacedata[root.tags.surface_index]
    local struct = surfacedata.structs[root.tags.unit_number]
    local new_multiplier = math.min(surfacedata.total_seams - surfacedata.total_miners + struct.multiplier, element.slider_value)
    mod.set_multiplier(surfacedata, struct, new_multiplier)

    -- there were not enough available seams
    if new_multiplier ~= element.slider_value then
      element.slider_value = new_multiplier -- visual mess
      -- local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
      -- player.create_local_flying_text{create_at_cursor = true, text = "not enough available seams."}
    end

    local surface_output = mod.get_surface_output(surfacedata, struct.entity.force, struct.multiplier)
    element.parent["texts"]["line-1"].caption = string.format("[entity=se-core-miner-drill] %03d/%03d", struct.multiplier, surfacedata.total_seams)
    element.parent["texts"]["line-2"].caption = string.format("[item=%s] %06.2f/s", surfacedata.fragment_name, surface_output)
  end
end)

remote.add_interface(mod_name, {
  get_total_miners_from_surface_index = function(surface_index) return storage.surfacedata[surface_index].total_miners end,
})

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local surfacedata = storage.surfacedata[deathrattle.surface_index]
    if surfacedata then
      local struct = surfacedata.structs[deathrattle.unit_number]
      surfacedata.structs[deathrattle.unit_number] = nil
      struct.beacon.destroy()
      surfacedata.total_miners = surfacedata.total_miners - struct.multiplier -- release reservation
    end
  end
end)

script.on_event(defines.events.on_post_entity_died, function(event)
  local surfacedata = storage.surfacedata[event.surface_index]
  if not surfacedata then return end

  local struct = surfacedata.structs[event.unit_number]
  if not struct then return end

  local ghost = event.ghost
  if ghost then
    local tags = ghost.tags or {}
    tags[mod_prefix .. "multiplier"] = struct.multiplier
    ghost.tags = tags
  end
end, {
  {filter = "type", type = "mining-drill"},
})
