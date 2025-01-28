local mod_prefix = "beacon-interface--"

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

local effects = {
  "speed",
  "productivity",
  "consumption",
  "pollution",
  "quality",
}

local gui_frame_name = mod_prefix .. "frame"

script.on_event(defines.events.on_gui_opened, function(event)
  local entity = event.entity

  if entity and entity.name == mod_prefix .. "beacon" then
    local player = game.get_player(event.player_index) --[[@as Luaplayer]]
    local frame = player.gui.relative[gui_frame_name]
    if frame then frame.destroy() end

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

    for _, effect in ipairs(effects) do
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
        minimum_value = -100,
        maximum_value =  100,
        value = 0,
        tags = {
          action = mod_prefix .. "slider-value-changed",
          effect = effect,
        }
      }

      local textfield = flow.add{
        type = "textfield",
        name = "textfield",
        text = "0",
        numeric = true,
        allow_decimal = true,
        allow_negative = true,
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

function set_effect(unit_number, effect, value)
  local bits = get_bits(value)
  game.print(serpent.line(bits))

  local struct = storage.structs[unit_number]
  assert(struct) -- todo: return if nil

  struct.inventory.clear()
  for i, bit in ipairs(bits) do
    if bit == 1 then
      if 0 > value and i == 15 then
        -- hmm
      else
        struct.inventory.insert({name = string.format(mod_prefix .. "module-%s-%d", effect, i)})
      end
    end
  end
end

script.on_event(defines.events.on_gui_value_changed, function(event)
  local tags = event.element.tags
  if tags and tags.action == mod_prefix .. "slider-value-changed" then
    local player = game.get_player(event.player_index) --[[@as Luaplayer]]
    local frame = player.gui.relative[gui_frame_name]
    if frame then
      frame.inner[tags.effect].textfield.text = tostring(event.element.slider_value)
      set_effect(frame.tags.unit_number, tags.effect, event.element.slider_value)
    end
  end
end)
