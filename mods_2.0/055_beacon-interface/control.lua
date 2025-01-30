local mod_prefix = "beacon-interface--"
local shared = require("shared")

script.on_init(function()
  storage.structs = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,
    inventory = entity.get_inventory(defines.inventory.beacon_modules),
    effects = {
      speed = 0,
      productivity = 0,
      consumption = 0,
      pollution = 0,
      quality = 0,
    },
  })
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = mod_prefix .. "beacon"},
  })
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
}

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity

  if entity and entity.name == mod_prefix .. "beacon" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.relative[gui_frame_name]
    if frame then frame.destroy() end

    local struct = storage.structs[entity.unit_number]
    assert(struct)

    frame = player.gui.relative.add{
      type = "frame",
      name = gui_frame_name,
      direction = "vertical",
      anchor = {
        gui = defines.relative_gui_type.beacon_gui,
        position = defines.relative_gui_position.right,
        name = mod_prefix .. "beacon",
      },
      tags = {
        unit_number = entity.unit_number,
      }
    }
    frame.style.top_padding = 8

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

      flow.add{
        type = "slider",
        name = "slider",
        minimum_value = -#slider_steps,
        maximum_value =  #slider_steps,
        value = struct.effects[effect],
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
      struct.inventory.insert({name = string.format(mod_prefix .. "module-%s-%d", effect, 16)})
    end
    local bits = get_bits(value)
    for i, bit in ipairs(bits) do
      if bit == 1 then
        local module_name = string.format(mod_prefix .. "module-%s-%d", effect, i)
        assert(struct.inventory.insert({name = module_name}), module_name)
      end
    end
  end
end

function set_effect(unit_number, effect, value)
  local struct = storage.structs[unit_number]
  assert(struct)

  struct.effects[effect] = value
  refresh_effects(struct)
end

script.on_event(defines.events.on_gui_value_changed, function(event)
  local tags = event.element.tags
  if tags and tags.action == mod_prefix .. "slider-value-changed" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.relative[gui_frame_name]
    if frame then
      local step = 0
      if 0 > event.element.slider_value then
        step = -slider_steps[math.abs(event.element.slider_value)]
      elseif event.element.slider_value > 0 then
        step = slider_steps[event.element.slider_value]
      end
      frame.inner[tags.effect].textfield.text = tostring(step)
      set_effect(frame.tags.unit_number, tags.effect, step)
    end
  end
end)

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

script.on_event(defines.events.on_gui_text_changed, function(event)
  local tags = event.element.tags
  if tags and tags.action == mod_prefix .. "textfield-text-changed" then
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local frame = player.gui.relative[gui_frame_name]
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
      set_effect(frame.tags.unit_number, tags.effect, strength)
    end
  end
end)

script.on_event(defines.events.on_player_setup_blueprint, function(event)
  local blueprint = event.stack
  if blueprint == nil then return end

  local blueprint_entities = blueprint.get_blueprint_entities() or {}
  for i, blueprint_entity in ipairs(blueprint_entities) do
    if blueprint_entity.name == mod_prefix .. "beacon" then
      game.print(serpent.line(blueprint_entity.items))
    end
  end
end)

commands.add_command("beacon-interface-selftest", "- Check if the bit modules are able to make up every strength.", function(command)
  local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
  if player.admin == false then
    player.print(string.format("[beacon-interface] due to lag only admins may run this."))
    return
  end

  local beacon = player.surface.create_entity{
    name = mod_prefix .. "beacon",
    force = player.force,
    position = player.position,
    raise_built = true,
  }
  local struct = assert(storage.structs[beacon.unit_number], "raise_built?")

  for percentage = shared.min_strength, shared.max_strength do
    set_effect(struct.id, "speed", percentage)
    assert_beacon_matches_config(struct)
  end

  beacon.destroy()
  player.print(string.format("[beacon-interface] all %d to %d strengths match.", shared.min_strength, shared.max_strength))
end)
