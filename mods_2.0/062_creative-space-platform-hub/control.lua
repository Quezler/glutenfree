require("shared")

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
end)

local function forget_hub(struct)
  storage.hubs[struct.id] = nil
  struct.rendering_1.destroy()
  struct.rendering_2.destroy()

  if not next(storage.hubs) then
    script.on_nth_tick(20, nil)
  end
end

local function on_nth_tick(event)
  for _, struct in pairs(storage.hubs) do
    if struct.entity.valid then
      game.print(event.tick)
    else
      forget_hub(struct)
    end
  end
end

script.on_load(function()
  if next(storage.hubs) then
    script.on_nth_tick(20, on_nth_tick)
  end
end)

script.on_event(mod_prefix .. "cycle-quality-up", function(event)
  if not about_space_platform_hub(event) then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local hub = player.surface.platform.hub --[[@as LuaEntity]]

  if storage.hubs[hub.unit_number] then return end

  local struct = new_struct(storage.hubs, {
    id = hub.unit_number,
    entity = hub,

    rendering_1 = nil,
    rendering_2 = nil,
  })

  struct.rendering_1 = rendering.draw_sprite{
    surface = player.surface,
    sprite = mod_prefix .. "platform-hub-3",
    target = hub,
    render_layer = "cargo-hatch",
  }

  struct.rendering_2 = rendering.draw_sprite{
    surface = player.surface,
    sprite = mod_prefix .. "platform-upper-hatch-occluder",
    target = hub,
    render_layer = "item-in-inserter-hand",
  }

  script.on_nth_tick(20, on_nth_tick)
end)

script.on_event(mod_prefix .. "cycle-quality-down", function(event)
  if not about_space_platform_hub(event) then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  local hub = player.surface.platform.hub --[[@as LuaEntity]]

  local struct = storage.hubs[hub.unit_number]
  if struct then forget_hub(struct) end
end)
