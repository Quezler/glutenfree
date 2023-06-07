local flib_bounding_box = require("__flib__/bounding-box")

-- local util = require("__core__.lualib.util")
-- if table_size(util.direction_vectors) ~= 8 then error('util.direction_vectors ~= 8') end

local ConcreteNetwork = require('scripts.concrete-network')

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

  global.deathrattles = {} -- [{surface_index, network_index}]
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

  ConcreteRoboport.mycelium(entity.surface, entity.position, entity.force)
end

---@param surface LuaSurface
---@param position TilePosition
---@param force LuaForce
function ConcreteRoboport.mycelium(surface, position, force)

  ---@type LuaTile
  local tile = surface.get_tile(position)

  ---@type LuaTile[]
  local tiles = surface.get_connected_tiles(position, {tile.name}, true)

  game.print('#tiles ' .. #tiles)
  game.print('minable? '.. tostring(tile.prototype.mineable_properties.minable))

  local roboports = {}

  for _, tile in ipairs(tiles) do
    -- todo: remove the roboports from any previous networks
    -- slughter performance to get all the roboports on these tiles
    local roboport = surface.find_entity('concrete-roboport', tile)
    if roboport then roboports[roboport.unit_number] = roboport end
  end

  game.print('#roboports ' .. table_size(roboports))
  if table_size(roboports) == 0 then return end -- no roboports, cannot create a network here

  -- assign id
  local network_index = global.next_network_index or 1
  global.next_network_index = network_index + 1

  -- setup struct
  local network = {
    index = network_index,
    surface_index = surface.index,
    force_index = force.index,

    min_x = nil,
    max_x = nil,
    min_y = nil,
    max_y = nil,

    roboports = 0,
    roboport = {},

    tiles = 0,
    tile = {},
  }

  local min_x = position.x - 2
  local max_x = position.x + 1
  local min_y = position.y - 2
  local max_y = position.y + 1

  for _, tile in ipairs(tiles) do
    if tile.x < min_x then min_x = tile.x end
    if tile.x > max_x then max_x = tile.x end
    if tile.y < min_y then min_y = tile.y end
    if tile.y > max_y then max_y = tile.y end

    local roboport_tile = ConcreteRoboport.get_or_create_roboport_tile(surface, tile, force)

    network.tiles = network.tiles + 1
    network.tile[roboport_tile.unit_number] = roboport_tile
  end

  network.min_x = min_x
  network.max_x = max_x
  network.min_y = min_y
  network.max_y = max_y
  
  -- store struct
  global.surfaces[surface.index].networks[network_index] = network

  -- highlight the network boundary on hovering any of its roboports
  for _, roboport in pairs(roboports) do
    ConcreteNetwork.add_roboport(network, roboport)
  end

end

---@param surface LuaSurface
---@param position TilePosition
---@param force LuaForce
---@return LuaEntity (roboport)
function ConcreteRoboport.get_or_create_roboport_tile(surface, position, force)
  local tiles = global.surfaces[surface.index].tiles

  if not tiles[position.x] then tiles[position.x] = {} end
  local tile = tiles[position.x][position.y]
  if not tile or not tile.valid then
    tile = surface.create_entity({
      name = 'concrete-roboport-tile',
      force = force,
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
  -- print('on_built_tile')
  local networks = global.surfaces[event.surface_index].networks

  local encroached = {}

  for _, network in pairs(networks) do
    for _, tile in ipairs(event.tiles) do
      -- one of the new tiles is touching the selection box of the network
      if flib_bounding_box.contains_position({{network.min_x - 1, network.min_y - 1}, {network.max_x + 1, network.max_y + 1}}, tile.position) then
        print(event.tick .. ' encroaching on network ' .. network.index)
        print('total networks: ' .. table_size(networks))
        encroached[network.index] = network
        -- print('skipping network id ' .. network.index)
        goto next_network
      end
    end
    ::next_network::
  end

  for _, network in pairs(encroached) do
    local roboport = table_first(network.roboport)
    ConcreteRoboport.mycelium(game.get_surface(event.surface_index), roboport.position, game.forces[network.force_index])
  end

end

function ConcreteRoboport.on_entity_destroyed(event)
  local tuple = global.deathrattles[event.registration_number]
  if tuple then global.deathrattles[event.registration_number] = nil
    local network = global.surfaces[tuple[1]].networks[tuple[2]]
    ConcreteNetwork.sub_roboport(network, {unit_number = event.unit_number})
    game.print(string.format('network %d destroyed', tuple[2]))
  end
end

return ConcreteRoboport

