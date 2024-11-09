local flib_position = require("__flib__.position")
local flib_bounding_box = require("__flib__.bounding-box")

-- local debug_mode = true

local Handler = {}

script.on_init(function()
  storage.playerdata = {}
end)

script.on_configuration_changed(function()
  storage.playerdata = {}

  rendering.clear("agricultural-tower-placement-helper")
end)

--

local function position_key(position)
  assert(position.x)
  assert(position.y)
  return string.format("[%g, %g]", position.x, position.y)
end

local function get_chunks_in_viewport(chunk_position)
  local chunk_positions = {}

  local x = chunk_position.x
  local y = chunk_position.y

  -- this gets all the chunks on my 1920 x 1080 screen when i fully zoom out
  local vertical = 2
  local horizontal = 4

  for i = y - vertical, y + vertical do
      for j = x - horizontal, x + horizontal do
          table.insert(chunk_positions, {x = j, y = i})
      end
  end

  return chunk_positions
end

local is_agricultural_tower_entity = {}
for _, entity in pairs(prototypes.entity) do
  is_agricultural_tower_entity[entity.name] = entity.type == "agricultural-tower"
end

local is_agricultural_tower_item = {}
for _, item in pairs(prototypes.item) do
  local place_result = item.place_result
  if place_result and is_agricultural_tower_entity[place_result.name] then
    is_agricultural_tower_item[item.name] = true
  else
    is_agricultural_tower_item[item.name] = false
  end
end

-- true, false, nil
local function is_player_holding_agricultural_tower(player)
  if player.cursor_ghost then
    return is_agricultural_tower_item[player.cursor_ghost.name.name]
  end

  if player.cursor_stack.valid_for_read then
    if player.cursor_stack.is_blueprint then
      for _, blueprint_entity in ipairs(player.cursor_stack.get_blueprint_entities() or {}) do
        if is_agricultural_tower_entity[blueprint_entity.name] then return true end
      end
    end
    return is_agricultural_tower_item[player.cursor_stack.prototype.name]
  end
end

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  assert(player)

  local playerdata = storage.playerdata[player.index]

  if playerdata == nil then
    if is_player_holding_agricultural_tower(player) then
      storage.playerdata[player.index] = {
        player_index = player.index,
        surface_index = player.surface.index,

        rectangles = {},
        seen_chunks = {},

        tile_render_objects = {},

        alt_mode = player.game_view_settings.show_entity_info,
      }

      Handler.tick_player(event)
    end
  else
    if is_player_holding_agricultural_tower(player) ~= true then
      for _, rectangle in pairs(playerdata.rectangles) do
        rectangle.destroy()
      end
      for _, tile_render_object in pairs(playerdata.tile_render_objects) do
        tile_render_object.destroy()
      end
      storage.playerdata[player.index] = nil
    end
  end

end)

script.on_event(defines.events.on_player_toggled_alt_mode, function(event)
  local playerdata = storage.playerdata[event.player_index]
  if playerdata then
    playerdata.alt_mode = event.alt_mode

    for tile_key, tile_render_object in pairs(playerdata.tile_render_objects) do
      if tile_render_object.valid then -- if the ore gets mined this kills itself
        tile_render_object.radius = playerdata.alt_mode and 0.2 or 0.1
      end
    end
  end
end)

--

local colors = {
  green  = {0.0, 0.9, 0.0, 1},
  yellow = {0.9, 0.9, 0.0, 1},
  red    = {0.9, 0.0, 0.0, 1},
}

-- todo: generate from prototypes.
local tile_name_to_color = {
  -- currently plantable for yumako
  ["natural-yumako-soil"   ] = colors.green,
  ["artificial-yumako-soil"] = colors.green,
  ["overgrowth-yumako-soil"] = colors.green,

  -- currently plantable for jellynut
  ["natural-jellynut-soil"   ] = colors.green,
  ["artificial-jellynut-soil"] = colors.green,
  ["overgrowth-jellynut-soil"] = colors.green,

  -- future plantable for yumako
  ["wetland-light-green-slime"] = colors.red,
  ["wetland-green-slime"      ] = colors.red,
  ["wetland-yumako"           ] = colors.yellow, -- artificial soil
  ["lowland-olive-blubber"    ] = colors.red,
  ["lowland-olive-blubber-2"  ] = colors.red,
  ["lowland-olive-blubber-3"  ] = colors.red,
  ["lowland-brown-blubber"    ] = colors.red,
  ["lowland-pale-green"       ] = colors.red,

  -- future plantable for jellynut
  ["wetland-pink-tentacle"] = colors.red,
  ["wetland-red-tentacle" ] = colors.red,
  ["wetland-jellynut"     ] = colors.yellow, -- artificial soil
  ["lowland-red-vein"     ] = colors.red,
  ["lowland-red-vein-2"   ] = colors.red,
  ["lowland-red-vein-3"   ] = colors.red,
  ["lowland-red-vein-4"   ] = colors.red,
  ["lowland-red-vein-dead"] = colors.red,
  ["lowland-red-infection"] = colors.red,
  ["lowland-cream-red"    ] = colors.red,
}

local tile_names = {}
for tile_name, color in pairs(tile_name_to_color) do
  table.insert(tile_names, tile_name)
end

function Handler.tick_player(event)
  local playerdata = storage.playerdata[event.player_index]
  if playerdata == nil then return end

  local player = assert(game.get_player(event.player_index))
  local surface = player.surface

  local chunk_position_with_player = flib_position.to_chunk(player.position)

  for _, chunk_position in ipairs(get_chunks_in_viewport(chunk_position_with_player)) do
    local chunk_key = position_key(chunk_position)
    if playerdata.seen_chunks[chunk_key] then goto continue end
    playerdata.seen_chunks[chunk_key] = true

    local left_top = flib_position.from_chunk(chunk_position)
    local right_bottom = {left_top.x + 32, left_top.y + 32}

    if debug_mode then
      local rectangle = rendering.draw_rectangle{
        surface = surface,

        left_top = left_top,
        right_bottom = right_bottom,

        color = {0.25, 0.25, 0.25, 0.1},
        filled = true,
        players = {player},
      }

      playerdata.rectangles[rectangle.id] = rectangle
    end

    local tiles = surface.find_tiles_filtered{
      area = {left_top, right_bottom},
      name = tile_names,
    }

    for _, tile in ipairs(tiles) do
      local color = tile_name_to_color[tile.name]
      -- game.print(tile.name .. serpent.line(color))

      if color then
        local tile_key = position_key(tile.position)
        playerdata.tile_render_objects[tile_key] = rendering.draw_circle{
          surface = playerdata.surface_index,

          target = {tile.position.x + 0.5, tile.position.y + 0.5},
          radius = playerdata.alt_mode and 0.2 or 0.1,

          color = color,
          filled = true,

          players = {playerdata.player_index},
        }
      end
    end

    ::continue::
  end
end

script.on_event(defines.events.on_player_changed_position, Handler.tick_player)
