require("shared")

local this = {}

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

local function on_created_entity(event)
  local entity = event.entity or event.destination

  -- if entity.name == "stone-wall" then
  --   entity.destructible = false
  --   return
  -- end

  if entity.name == mod_prefix .. "infinity-pipe" then
    entity.destroy()
    return
  end

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,

    fuel_pipe = nil,
    oxidizer_pipe = nil,
    thrusters = {},
  })

  struct.fuel_pipe = entity.surface.create_entity{
    name = mod_prefix .. "infinity-pipe",
    force = entity.force,
    position = {entity.position.x - 0.5, entity.position.y}
  }
  struct.fuel_pipe.destructible = false
  struct.fuel_pipe.set_infinity_pipe_filter({name = "thruster-fuel", percentage = 1})
  struct.fuel_pipe.fluidbox.add_linked_connection(0, entity, 1)

  struct.oxidizer_pipe = entity.surface.create_entity{
    name = mod_prefix .. "infinity-pipe",
    force = entity.force,
    position = {entity.position.x + 0.5, entity.position.y}
  }
  struct.oxidizer_pipe.destructible = false
  struct.oxidizer_pipe.set_infinity_pipe_filter({name = "thruster-oxidizer", percentage = 1})
  struct.oxidizer_pipe.fluidbox.add_linked_connection(0, entity, 3)

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {"thruster-interface", struct.id}

  if event.tags and event.tags[mod_directory] and event.tags[mod_directory].thrusters then
    this.set_thrusters(struct, tonumber(event.tags[mod_directory].thrusters))
  else
    this.set_thrusters(struct, entity.surface.count_entities_filtered{
      name = mod_prefix .. "thruster",
      position = entity.position,
    })
  end
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, on_created_entity, {
    -- {filter = "name", name = "stone-wall"},
    {filter = "name", name = mod_name},
    {filter = "name", name = mod_prefix .. "infinity-pipe"},
  })
end

local gui_frame_name = mod_prefix .. "frame"
local gui_slider_name = mod_prefix .. "slider"

local function open_gui(player, entity)
  local frame = player.gui.screen[gui_frame_name]
  if frame then frame.destroy() end

  local struct = storage.structs[entity.unit_number]
  assert(struct)

  frame = player.gui.screen.add{
    type = "frame",
    name = gui_frame_name,
    direction = "vertical",
    caption = entity.prototype.localised_name,
    tags = {
      unit_number = entity.unit_number,
    }
  }

  local inner = frame.add{
    type = "frame",
    name = "inner",
    style = "inside_shallow_frame_with_padding",
    direction = "vertical",
  }

  local entity_preview_frame = inner.add{
    type = "frame",
    style = "deep_frame_in_shallow_frame",
  }

  local entity_preview = entity_preview_frame.add{
    type = "entity-preview",
    style = "wide_entity_button",
  }
  entity_preview.entity = entity

  local flow = inner.add{
    type = "flow",
    name = "flow",
    style = "horizontal_flow",
  }
  flow.style.top_margin = 5
  flow.style.bottom_margin = 5

  local min = flow.add{
    type = "label",
    caption = "0",
  }
  min.style.font = "default-bold"
  min.style.minimal_width = 24 -- width of max (CTRL + F6)
  flow.add{
    type = "flow",
  }.style.horizontally_stretchable = true
  flow.add{
    type = "label",
    name = "?",
    caption = tostring(#struct.thrusters),
  }.style.font = "default-bold"
  flow.add{
    type = "flow",
  }.style.horizontally_stretchable = true
  local max = flow.add{
    type = "label",
    caption = "100",
  }
  max.style.font = "default-bold"

  local slider = inner.add{
    type = "slider",
    name = gui_slider_name,
    minimum_value = 0,
    value = #struct.thrusters,
    maximum_value = 100,
  }

  player.opened = frame
  frame.force_auto_center()
end

---@param event EventData.CustomInputEvent
script.on_event(mod_prefix .. "open-gui", function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local selected = player.selected
  if selected and selected.name == mod_name and player.is_cursor_empty() then
    open_gui(player, selected)
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  local element = event.element
  if element and element.name == gui_frame_name then
    element.destroy()
  end
end)

function this.add_thruster(struct)
  local parent = struct.thrusters[#struct.thrusters] or struct.entity
  local thruster = struct.entity.surface.create_entity{
    name = mod_prefix .. "thruster",
    force = struct.entity.force,
    position = struct.entity.position,
    quality = struct.entity.quality,
    create_build_effect_smoke = false,
  }
  thruster.destructible = false
  thruster.fluidbox.add_linked_connection(1, parent, 2)
  thruster.fluidbox.add_linked_connection(3, parent, 4)
  table.insert(struct.thrusters, thruster)
end

function this.remove_thruster(struct)
  struct.thrusters[#struct.thrusters].destroy()
  struct.thrusters[#struct.thrusters] = nil
end

function this.set_thrusters(struct, amount)
  while amount > #struct.thrusters do
    this.add_thruster(struct)
  end

  while amount < #struct.thrusters do
    this.remove_thruster(struct)
  end
end

script.on_event(defines.events.on_gui_value_changed, function(event)
  local element = event.element
  if element and element.name == gui_slider_name then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.screen[gui_frame_name]
    if frame then
      frame["inner"]["flow"]["?"].caption = tostring(element.slider_value)
      this.set_thrusters(storage.structs[frame.tags.unit_number], element.slider_value)
    end
  end
end)

local deathrattles = {
  ["thruster-interface"] = function (deathrattle)
    local struct = storage.structs[deathrattle[2]]
    if struct then
      storage.structs[struct.id] = nil
      struct.fuel_pipe.destroy()
      struct.oxidizer_pipe.destroy()
      for _, thruster in ipairs(struct.thrusters) do
        thruster.destroy()
      end
    end
  end,
}

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    deathrattles[deathrattle[1]](deathrattle)
  end
end)

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  local blueprint = event.stack
  if blueprint == nil then return end

  local blueprint_entities = blueprint.get_blueprint_entities() or {}
  for i, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == mod_name then
      local entity = event.mapping.get()[i]
      if entity and entity.name == mod_name then
        blueprint.set_blueprint_entity_tag(i, mod_directory, {thrusters = #storage.structs[entity.unit_number].thrusters})
      else
        log(string.format("failed to save thruster count due to modified blueprint mapping:"))
        log(string.format("expected 'thruster-interface' at #%d but found '%s'", i, entity and entity.name or "nil"))
      end
    end
  end
end)

script.on_event(defines.events.on_post_entity_died, function(event)
  local ghost = event.ghost

  if ghost and ghost.ghost_name == mod_name then
    local tags = ghost.tags or {}
    tags[mod_directory] = {thrusters = #storage.structs[event.unit_number].thrusters}
    ghost.tags = tags
  end
end, {
  {filter = "type", type = "thruster"},
})
