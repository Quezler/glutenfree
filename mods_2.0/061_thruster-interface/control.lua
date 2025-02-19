require("shared")

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

local function on_created_entity(event)
  local entity = event.entity or event.destination

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

  local entity_preview = inner.add{
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
    caption = "?",
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

local function add_thruster(struct)
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

script.on_event(defines.events.on_gui_value_changed, function(event)
  local element = event.element
  if element and element.name == gui_slider_name then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.screen[gui_frame_name]
    if frame then
      frame["inner"]["flow"]["?"].caption = tostring(element.slider_value)
      add_thruster(storage.structs[frame.tags.unit_number])
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
