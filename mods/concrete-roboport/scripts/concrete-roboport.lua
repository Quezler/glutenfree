local flib_bounding_box = require("__flib__/bounding-box")

--

local ConcreteRoboport = {}

function ConcreteRoboport.on_init(event)
  global.surfaces = {}

  for _, surface in pairs(game.surfaces) do
    ConcreteRoboport.on_surface_created({surface_index = surface.index})
  end

  -- global.next_network_index = 1
  -- global.networks = {}

  global.unit_number_to_network_index = {}

  global.player_index_to_highlight_box = {}
end

function ConcreteRoboport.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    networks = {},
    tiles = {},
  }
end

function ConcreteRoboport.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end

function ConcreteRoboport.on_created_entity(event)
  local entity = event.created_entity or event.entity or event.destination
  if entity.name ~= "concrete-roboport" then return end
  game.print('concrete roboport created')

  local network_index = global.next_network_index or 1
  global.next_network_index = network_index + 1

  -- all the tiles under the roboport
  local min_x = entity.position.x - 2
  local max_x = entity.position.x + 1
  local min_y = entity.position.y - 2
  local max_y = entity.position.y + 1

  -- should we care about all 3 tiles, or just the center one?
  local tile = entity.surface.get_tile(entity.position)
  -- todo: restrict to manually placed tiles with `tile.prototype.mineable_properties.minable` to avoid scanning the world?
  local tiles = entity.surface.get_connected_tiles(entity.position, {tile.name}, true)
  game.print('#tiles ' .. #tiles)

  game.print('minable? '.. tostring(tile.prototype.mineable_properties.minable))

  for _, tile in ipairs(tiles) do
    if tile.x < min_x then min_x = tile.x end
    if tile.x > max_x then max_x = tile.x end
    if tile.y < min_y then min_y = tile.y end
    if tile.y > max_y then max_y = tile.y end
    ConcreteRoboport.get_or_create_roboport_tile(entity, tile)
  end

  local network = {
    -- todo: store the tile(s) and only check for overlap if it matches by name
    index = network_index,

    -- area = {left_top = {x = min_x, y = min_y}, right_bottom = {x = max_x, y = max_y}},

    -- the tile positions, needs to +/-'d before use in drawing highlight boxes or doing bounding box checks
    min_x = min_x,
    max_x = max_x,
    min_y = min_y,
    max_y = max_y,
  }

  global.surfaces[entity.surface.index].networks[network_index] = network

  global.unit_number_to_network_index[entity.unit_number] = network_index -- todo: doesn't store a surface index yet
end

function ConcreteRoboport.get_or_create_roboport_tile(entity, position)
  local surface_index = entity.surface.index
  local tiles = global.surfaces[surface_index].tiles

  if not tiles[position.x] then tiles[position.x] = {} end
  local tile = tiles[position.x][position.y]
  if not tile or not tile.valid then
    tile = entity.surface.create_entity({
      name = 'concrete-roboport-tile',
      force = entity.force,
      position = position,
    })
    tiles[position.x][position.y] = tile
  end

  return tile
end

function ConcreteRoboport.on_selected_entity_changed(event)
  local player = game.get_player(event.player_index)

  if global.player_index_to_highlight_box[player.index] then
     global.player_index_to_highlight_box[player.index].destroy()
     global.player_index_to_highlight_box[player.index] = nil
  end

  if player.selected and player.selected.unit_number then
    local network_index = global.unit_number_to_network_index[player.selected.unit_number]
    if network_index then
      local network = global.surfaces[player.selected.surface.index].networks[network_index]
      local entity = player.surface.create_entity{
        name = 'highlight-box',
        position = {0, 0},
        -- bounding_box = network.area,
        bounding_box = {{network.min_x, network.min_y}, {network.max_x + 1, network.max_y + 1}},
        box_type = "train-visualization",
        render_player_index = player.index,
        time_to_live = 60 * 60 * 60, -- timeout after a minute in case we lose track of it
      }

      global.player_index_to_highlight_box[player.index] = entity
    end
  end
end

function ConcreteRoboport.on_built_tile(event) -- player & robot
  local networks = global.surfaces[event.surface_index].networks

  for _, tile in ipairs(event.tiles) do
    for _, network in pairs(networks) do
      -- local area = {left_top = {x = network.min_x - 1, y = network.min_y - 1}, right_bottom = {x = network.max_x + 1, y = network.max_y + 1}}
      -- one of the new tiles is within the bounding box of the network
      if flib_bounding_box.contains_position({{network.min_x - 1, network.min_y - 1}, {network.max_x + 1, network.max_y + 1}}, tile.position) then
        game.print(event.tick .. ' encroaching on network ' .. network.index)
      end
    end
  end
end

return ConcreteRoboport

