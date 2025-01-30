shared = require("shared")
Interface = require("scripts.interface")
require("scripts.compatibility")
require("scripts.commands")

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  entity.operable = false

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,
    inventory = entity.get_inventory(defines.inventory.beacon_modules),
    effects = shared.get_empty_effects(),
  })

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {"struct", struct.id}

  -- /c game.player.selected.clone{position = game.player.position}
  for _, item in ipairs(struct.inventory.get_contents()) do
    local effect, strength = table.unpack(shared.module_name_to_effect_and_strength[item.name])
    struct.effects[effect] = struct.effects[effect] + (strength * item.count)
  end

  local tags = event.tags
  if tags and tags["__beacon-interface__"] then
    Interface.set_effects(entity.unit_number, tags["__beacon-interface__"])
  end
end

local is_beacon_interface = {}
for _, entity_prototype in pairs(prototypes.entity) do
  if entity_prototype.type == "beacon" then
    if (entity_prototype.allowed_module_categories or {})[mod_prefix .. "module-category"] then
      is_beacon_interface[entity_prototype.name] = true
    end
  end
end
-- log(serpent.line(is_beacon_interface))

local on_created_entity_filters = {}
for entity_name, _ in pairs(is_beacon_interface) do
  table.insert(on_created_entity_filters, {filter = "name", name = entity_name})
end
-- log(serpent.line(on_created_entity_filters))

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, on_created_entity_filters)
end

local gui_frame_name = mod_prefix .. "frame"

local slider_steps = {
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
  10,
  20,
  30,
  40,
  50,
  60,
  70,
  80,
  90,
  100,
  200,
  300,
  400,
  500,
  600,
  700,
  800,
  900,
  1000,
  10000,
}

local function get_slider_step_from_number(number)
  local highest = 0
  for i, step in ipairs(slider_steps) do
    if math.abs(number) >= step then
      highest = i
    else
      break
    end
  end
  return number > 0 and highest or -highest
end

local function open_gui(entity, player)
  local frame = player.gui.screen[gui_frame_name]
  if frame then frame.destroy() end

  local struct = storage.structs[entity.unit_number]
  assert(struct)

  frame = player.gui.screen.add{
    type = "frame",
    name = gui_frame_name,
    direction = "vertical",
    caption = {"entity-name." .. mod_prefix .. "beacon"},
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

  for _, effect in ipairs(shared.effects) do
    local flow = inner.add{
      type = "flow",
      name = effect,
      style = "horizontal_flow",
    }
    flow.style.vertical_align = "center"

    local piston = flow.add{
      type = "flow",
    }
    piston.style.horizontally_stretchable = true

    local label = flow.add{
      type = "label",
      caption = string.upper(string.sub(effect, 1, 1)) .. string.sub(effect, 2),
    }
    label.style.font = "default-bold"
    if effect == "productivity" then
      label.caption = "[img=info] " .. label.caption
      label.tooltip = {"beacon-interface.productivity-tooltip"}
    elseif effect == "quality" then
      label.caption = "[img=info] " .. label.caption
      label.tooltip = {"beacon-interface.quality-tooltip"}
    end

    flow.add{
      type = "slider",
      name = "slider",
      minimum_value = -#slider_steps,
      maximum_value =  #slider_steps,
      value = get_slider_step_from_number(struct.effects[effect]),
      tags = {
        action = mod_prefix .. "slider-value-changed",
        effect = effect,
      }
    }

    local textfield = flow.add{
      type = "textfield",
      name = "textfield",
      text = tostring(struct.effects[effect]),
      numeric = true,
      allow_negative = true,
      tags = {
        action = mod_prefix .. "textfield-text-changed",
        effect = effect,
      }
    }
    textfield.style.width = 100
    textfield.style.horizontal_align = "center"
  end

  player.opened = frame
  frame.force_auto_center()
end

script.on_event(mod_prefix .. "open-gui", function(event)
  local selected_prototype = event.selected_prototype --[[@as SelectedPrototypeData?]]
  if selected_prototype and selected_prototype.base_type == "entity" and selected_prototype.name == mod_prefix .. "beacon" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local beacon = player.surface.find_entity({name = mod_prefix .. "beacon", quality = selected_prototype.quality}, event.cursor_position)
    if beacon then
      open_gui(beacon, player)
    end
  end
end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.element and event.element.name == gui_frame_name then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    event.element.destroy()
  end
end)

function get_bits(number)
  local bits = {}
  for i = 0, 15 do
      bits[i + 1] = bit32.band(number, bit32.lshift(1, i)) ~= 0 and 1 or 0
  end
  return bits
end

function assert_beacon_matches_config(struct)
  local effects = struct.entity.effects

  for effect, value in pairs(struct.effects) do
    local effect_strength = (effects[effect] or 0) * 100
    local within_bounds = 0.01 > math.abs(effect_strength - value)
    assert(within_bounds, string.format("expected effect %s to be %f but was %f", effect, value, effect_strength))
  end
end

function refresh_effects(struct)
  struct.inventory.clear()
  for effect, value in pairs(struct.effects) do
    if 0 > value then
      struct.inventory.insert({name = string.format(mod_prefix .. "%s-module-16", effect)})
    end
    local bits = get_bits(value)
    for i, bit in ipairs(bits) do
      if bit == 1 then
        local two_character_number = string.format("%02d", i)
        local module_name = string.format(mod_prefix .. "%s-module-%s", effect, two_character_number)
        assert(struct.inventory.insert({name = module_name}), module_name)
      end
    end
  end
end

script.on_event(defines.events.on_gui_value_changed, function(event)
  local tags = event.element.tags
  if tags and tags.action == mod_prefix .. "slider-value-changed" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.screen[gui_frame_name]
    if frame then
      local step = 0
      if 0 > event.element.slider_value then
        step = -slider_steps[math.abs(event.element.slider_value)]
      elseif event.element.slider_value > 0 then
        step = slider_steps[event.element.slider_value]
      end
      frame.inner[tags.effect].textfield.text = tostring(step)
      Interface.set_effect(frame.tags.unit_number, tags.effect, step)
    end
  end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  local tags = event.element.tags
  if tags and tags.action == mod_prefix .. "textfield-text-changed" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.screen[gui_frame_name]
    if frame then
      local strength = tonumber(event.element.text) or 0
      if strength > shared.max_strength then
        strength = shared.max_strength
        event.element.text = tostring(shared.max_strength)
      elseif strength < shared.min_strength then
        strength = shared.min_strength
        event.element.text = tostring(shared.min_strength)
      end
      frame.inner[tags.effect].slider.slider_value = get_slider_step_from_number(strength)
      Interface.set_effect(frame.tags.unit_number, tags.effect, strength)
    end
  end
end)

local function get_effects_from_blueprint_entity(blueprint_entity)
  local effects = shared.get_empty_effects()

  for _, blueprint_insert_plan in ipairs(blueprint_entity.items or {}) do
    local effect, strength = table.unpack(shared.module_name_to_effect_and_strength[blueprint_insert_plan.id.name])
    effects[effect] = effects[effect] + (strength * #blueprint_insert_plan.items.in_inventory)
  end

  return effects
end

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  local blueprint = event.stack
  if blueprint == nil then return end

  local blueprint_entities = blueprint.get_blueprint_entities() or {}
  for i, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == mod_prefix .. "beacon" then
      blueprint_entity.tags = blueprint_entity.tags or {}
      blueprint_entity.tags["__beacon-interface__"] = get_effects_from_blueprint_entity(blueprint_entity)
      blueprint_entity.items = nil
    end
  end
  blueprint.set_blueprint_entities(blueprint_entities)
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
  local struct = assert(storage.structs[event.entity.unit_number])
  struct.inventory.clear()
  struct.effects = shared.get_empty_effects()
end, on_created_entity_filters)

script.on_event(defines.events.on_marked_for_deconstruction, function(event)
  local struct = assert(storage.structs[event.entity.unit_number])
  struct.inventory.clear()
  struct.effects = shared.get_empty_effects()
end, on_created_entity_filters)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle[1] == "struct" then
      storage.structs[deathrattle[2]] = nil
    else
      error(serpent.block(deathrattle))
    end
  end
end)
