require("shared")

local INTERVAL = 60

local function about_space_platform_hub(event)
  -- game.print(serpent.block(event.selected_prototype))
  return event.selected_prototype and event.selected_prototype.derived_type == "space-platform-hub"
end

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

script.on_init(function()
  storage.hubs = {}
  storage.blacklist = {}
end)

script.on_configuration_changed(function()
  storage.blacklist = {}
end)

local function forget_hub(struct)
  storage.hubs[struct.id] = nil
  struct.rendering_1.destroy()
  struct.rendering_2.destroy()

  if not next(storage.hubs) then
    script.on_nth_tick(INTERVAL, nil)
  end
end

local function tick_hub(struct)
  if not struct.entity.valid then
    return forget_hub(struct)
  end

  local section = struct.sections.sections[1]
  if section == nil or section.type ~= defines.logistic_section_type.request_missing_materials_controlled then return end

  for _, filter in pairs(section.filters) do
    if filter.min > 0 and storage.blacklist[filter.value.name] ~= true then
      local item = {name = filter.value.name, count = filter.min, quality = filter.value.quality}
      local missing = filter.min - struct.inventory.get_item_count(item)
      if missing > 0 then
        struct.inventory.insert({name = filter.value.name, count = missing, quality = filter.value.quality})
        log(string.format("gave platform '%s' %d x %s (%s)", struct.entity.name, missing, item.name, item.quality))
      end
    end
  end
end

local function on_nth_tick(event)
  -- game.print("on_nth_tick " .. event.tick)
  for _, struct in pairs(storage.hubs) do
    tick_hub(struct)
  end
end

script.on_load(function()
  if next(storage.hubs) then
    script.on_nth_tick(INTERVAL, on_nth_tick)
  end
end)

local function enlist_hub(entity)
  local struct = new_struct(storage.hubs, {
    id = entity.unit_number,
    entity = entity,

    sections = entity.get_logistic_sections(),
    inventory = entity.get_inventory(defines.inventory.hub_main),

    rendering_1 = nil,
    rendering_2 = nil,
  })

  struct.rendering_1 = rendering.draw_sprite{
    surface = entity.surface,
    sprite = mod_prefix .. "platform-hub-3",
    target = entity,
    render_layer = "cargo-hatch",
  }

  struct.rendering_2 = rendering.draw_sprite{
    surface = entity.surface,
    sprite = mod_prefix .. "platform-upper-hatch-occluder",
    target = entity,
    render_layer = "item-in-inserter-hand",
  }

  script.on_nth_tick(INTERVAL, on_nth_tick)
  tick_hub(struct)
end

script.on_event(mod_prefix .. "cycle-quality-up", function(event)
  if not about_space_platform_hub(event) then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.is_cursor_empty() == false then return end
  local hub = player.surface.platform.hub --[[@as LuaEntity]]

  if storage.hubs[hub.unit_number] then return end

  local allowed_to_enable = player.cheat_mode or player.physical_controller_type == defines.controllers.editor
  if not allowed_to_enable then return end

  enlist_hub(hub)
end)

script.on_event(mod_prefix .. "cycle-quality-down", function(event)
  if not about_space_platform_hub(event) then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.is_cursor_empty() == false then return end
  local hub = player.surface.platform.hub --[[@as LuaEntity]]

  local struct = storage.hubs[hub.unit_number]
  if struct then forget_hub(struct) end
end)

remote.add_interface("creative-space-platform-hub", {
  blacklist = function(item_name)
    assert(prototypes.item[item_name])
    storage.blacklist[item_name] = true
  end,
})

if script.active_mods["EditorExtensions"] then
  script.on_event(defines.events.on_surface_created, function(event)
    local platform = game.surfaces[event.surface_index].platform
    if platform then
      game.print("1 " .. serpent.line(platform.hub))
      game.print("2 " .. serpent.line(platform.apply_starter_pack()))
      enlist_hub(platform.hub or platform.apply_starter_pack())
    end
  end)
end
