local mod = {}

--- @return number
mod.get_core_seams_for_radius = function(radius)
  return 5 + math.floor(95 * radius / 10000)
end

mod.get_core_fragment_mining_time = function(fragment_name)
  return prototypes.entity[fragment_name].mineable_properties.mining_time
end

mod.get_core_fragments_per_second = function(fragment_name, zone_radius, mining_productivity, core_miners)
  return ((100 / mod.get_core_fragment_mining_time(fragment_name)) * ((zone_radius + 5000) / 5000) * mining_productivity * core_miners) / math.sqrt(core_miners)
end

local gui_frame_name = "se-core-miner-fragments-frame"
local gui_inner_name = "se-core-miner-fragments-inner"

mod.open_gui = function(player, entity, surface_output)
  local frame = player.gui.relative[gui_frame_name]
  if frame then frame.destroy() end

  local fragment_name = entity.mining_target.name

  frame = player.gui.relative.add{
    type = "frame",
    name = gui_frame_name,
    caption = "Fragment rate",
    anchor = {
      gui = defines.relative_gui_type.mining_drill_gui,
      position = defines.relative_gui_position.right,
      name = "se-core-miner-drill",
    }
  }

  local inner = frame.add{
    type = "frame",
    name = gui_inner_name,
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  local surface_label = inner.add{
    type = "label",
    caption = entity.surface.localised_name or entity.surface.name,
  }
  surface_label.style.font = "default-bold"

  local fragment_label = inner.add{
    type = "label",
    caption = {"", string.format("[entity=%s] ", fragment_name), entity.mining_target.localised_name[2]},
  }
  fragment_label.style.font = "default-semibold"

  local rate_label = inner.add{
    type = "label",
    caption = string.format("[entity=se-core-miner-drill] %.2f/s", tostring(surface_output)),
  }
end

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity
  if entity and entity.name == "se-core-miner-drill" then
    local zone = remote.call("space-exploration", "get_zone_from_surface_index", {surface_index = entity.surface.index})
    if not zone then return end -- how did you even place this outside a zone?

    if not entity.mining_target then return end
    local fragment_name = entity.mining_target.name

    local mining_productivity = 1 + entity.force.mining_drill_productivity_bonus
    local core_miners = mod.get_core_seams_for_radius(zone.radius)
    local surface_output = mod.get_core_fragments_per_second(fragment_name, zone.radius, mining_productivity, core_miners)

    log(surface_output) -- core miners on every seam with diminishing returns
    if script.active_mods["se-core-miner-no-diminishing-returns"] then
      surface_output = mod.get_core_fragments_per_second(fragment_name, zone.radius, mining_productivity, 1) * core_miners
      log(surface_output) -- core miners on every seam without diminishing returns
    end

    mod.open_gui(game.get_player(event.player_index), entity, surface_output)
  end
end)

commands.add_command("se-core-miner-set-output", nil, function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  local entity = player.selected

  if entity and entity.name == "se-core-miner-drill" then
    local fragment_name = entity.mining_target.name
    local fragment_mining_time = mod.get_core_fragment_mining_time(fragment_name)
    entity.mining_target.amount = 10000 * fragment_mining_time * (tonumber(command.parameter) or 1) -- 1/s
  end
end)
