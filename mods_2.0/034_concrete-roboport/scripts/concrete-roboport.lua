-- local util = require("__core__.lualib.util")
-- if table_size(util.direction_vectors) ~= 8 then error("util.direction_vectors ~= 8") end

local ConcreteNetwork = require("scripts.concrete-network")

--

local function position_inside_area(position, area)
 return area[1][1] <= position.x
    and area[1][2] <= position.y
    and area[2][1] >= position.x
    and area[2][2] >= position.y
end

local function assert_tile_position(position)
  assert(position.x == math.floor(position.x))
  assert(position.y == math.floor(position.y))
  return position
end

local function tile_position_to_key(position)
  assert_tile_position(position)
  return position.x .. "," .. position.y
end

function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local mod = {}
local ConcreteRoboport = {}

local whitelisted_tiles = {}
for _, tile in pairs(prototypes.tile) do
  if tile.mineable_properties.minable then
    whitelisted_tiles[tile.name] = true
  end
end
log("whitelisted_tiles: " .. serpent.block(whitelisted_tiles))

function ConcreteRoboport.on_init()
  storage.surfacedata = {}
  mod.refresh_surfacedata()

  storage.invalid = game.create_inventory(0)
  storage.invalid.destroy()

  storage.next_network_index = 1

  -- storage.unit_number_to_network_index = {}

  -- storage.player_index_to_highlight_box = {}

  storage.deathrattles = {} -- {registration_number = {surface_index = #, network_index = #}}
end

function ConcreteRoboport.on_configuration_changed(event)
  mod.refresh_surfacedata()
end

function mod.refresh_surfacedata()
  -- deleted old
  for surface_index, surfacedata in pairs(storage.surfacedata) do
    if surfacedata.surface.valid == false then
      storage.surfacedata[surface_index] = nil
    end
  end

  -- created new
  for _, surface in pairs(game.surfaces) do
    storage.surfacedata[surface.index] = storage.surfacedata[surface.index] or {
      surface = surface,
      networks = {},
      tiles = {},

      roboports = {},
      roboport_at = {}, -- {tile_position_to_key = LuaEntity}

      abandoned_roboports = {}, -- {unit_number = LuaEntity}
      abandoned_tiles = {}, -- {unit_number = LuaEntity}
    }
  end
end

script.on_event(defines.events.on_surface_created, mod.refresh_surfacedata)
script.on_event(defines.events.on_surface_deleted, mod.refresh_surfacedata)

function ConcreteRoboport.on_created_entity(event)
  local entity = event.entity or event.destination

  -- ensure the tile is not created or cloned
  if entity.name == mod_prefix .. "tile" then
    entity.destroy()
    return
  end

  local tile_position = {x = math.floor(entity.position.x), y = math.floor(entity.position.y)}

  local surfacedata = storage.surfacedata[entity.surface.index]
  local struct = new_struct(surfacedata.roboports, {
    id = entity.unit_number,
    tile_position = tile_position,
    tile_position_key = tile_position_to_key(tile_position),
    last_network_index = nil, -- is allowed to point at nonexistant networks
  })
  surfacedata.roboport_at[struct.tile_position_key] = entity

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {
    name = "concrete-roboport",
    surface_index = entity.surface.index,
    roboport_id = struct.id,
  }

  ConcreteRoboport.mycelium(entity.surface, struct.tile_position, entity.force)
end

---@param surface LuaSurface
---@param position TilePosition
---@param force LuaForce
function ConcreteRoboport.mycelium(surface, position, force)
  assert_tile_position(position)

  ---@type LuaTile
  ---@diagnostic disable-next-line: param-type-mismatch, missing-parameter
  local origin_tile = surface.get_tile(position)
  if not whitelisted_tiles[origin_tile.name] then
    return
  end

  local surfacedata = storage.surfacedata[surface.index]

  ---@type TilePosition[]
  local tiles = surface.get_connected_tiles(position, {origin_tile.name}, true)
  local roboports = {}

  for _, tile_position in ipairs(tiles) do
    -- todo: remove the roboports from any previous networks
    -- slughter performance to get all the roboports on these tiles
    local roboport = surfacedata.roboport_at[tile_position_to_key(tile_position)]
    if roboport and roboport.valid then roboports[roboport.unit_number] = roboport end
  end

  -- assign id
  local network_index = storage.next_network_index
  storage.next_network_index = network_index + 1

  log(string.format("creating network #%d with %d roboports and %d tiles.", network_index, table_size(roboports), #tiles))

  -- setup struct
  local network = {
    index = network_index,
    surface_index = surface.index,
    force_index = force.index,

    min_x = position.x,
    max_x = position.x,
    min_y = position.y,
    max_y = position.y,

    roboports = 0,
    roboport = {},

    tiles = 0,
    tile = {},

    bounding_box = storage.invalid,
  }

  surfacedata.networks[network_index] = network

  ConcreteNetwork.increase_bounding_box_to_contain_tiles(network, tiles)
  for _, tile in ipairs(tiles) do
    local roboport_tile = ConcreteRoboport.get_or_create_roboport_tile(surface, tile, force)
    surfacedata.abandoned_tiles[roboport_tile.unit_number] = nil

    network.tiles = network.tiles + 1
    network.tile[roboport_tile.unit_number] = roboport_tile
  end

  for _, roboport in pairs(roboports) do
    ConcreteNetwork.add_roboport(network, roboport)
  end
end

---@param surface LuaSurface
---@param position TilePosition
---@param force LuaForce
---@return LuaEntity (roboport)
function ConcreteRoboport.get_or_create_roboport_tile(surface, position, force)
  local tiles = storage.surfacedata[surface.index].tiles
  local key = tile_position_to_key(position)
  local tile = tiles[key]

  if (not tile) or (not tile.valid) then
    tile = surface.create_entity({
      name = mod_prefix .. "tile",
      force = force,
      position = position,
    })
    tiles[key] = tile
  end

  return tile --[[@as LuaEntity]]
end

-- function ConcreteRoboport.on_selected_entity_changed(event)
--   local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

--   if storage.player_index_to_highlight_box[player.index] then
--      storage.player_index_to_highlight_box[player.index].destroy()
--      storage.player_index_to_highlight_box[player.index] = nil
--   end

--   if player.selected and player.selected.unit_number then
--     local network_index = storage.unit_number_to_network_index[player.selected.unit_number]
--     if network_index then
--       local network = storage.surfacedata[player.selected.surface.index].networks[network_index]
--       local entity = player.surface.create_entity{
--         name = "highlight-box",
--         position = {0, 0},
--         bounding_box = {{network.min_x - 0.2, network.min_y - 0.2}, {network.max_x + 1 + 0.2, network.max_y + 1 + 0.2}},
--         box_type = "train-visualization",
--         render_player_index = player.index,
--         time_to_live = 60 * 60 * 60, -- timeout after a minute in case we lose track of it
--       }

--       storage.player_index_to_highlight_box[player.index] = entity
--     end
--   end
-- end

function ConcreteRoboport.on_built_tile(event) -- player & robot
  -- print("on_built_tile")
  local surfacedata = storage.surfacedata[event.surface_index]
  local networks = surfacedata.networks

  local encroached = {}

  for _, network in pairs(networks) do
    local advanced_tiles = {{network.min_x - 1, network.min_y - 1}, {network.max_x + 1, network.max_y + 1}}
    for _, tile in ipairs(event.tiles) do
      -- one of the new tiles is touching the selection box of the network
      if position_inside_area(tile.position, advanced_tiles) then
        log(event.tick .. " encroaching on network " .. network.index)
        log("total networks: " .. table_size(networks))
        encroached[network.index] = network
        -- log("skipping network id " .. network.index)
        goto next_network
      end
    end
    ::next_network::
  end

  for _, network in pairs(encroached) do
    ConcreteNetwork.destroy(network)
  end

  for _, tile in ipairs(event.tiles) do
    local roboport = surfacedata.roboport_at[tile_position_to_key(tile.position)]
    if roboport and roboport.valid then
      surfacedata.abandoned_roboports[roboport.unit_number] = roboport
    end
  end

  for unit_number, roboport in pairs(surfacedata.abandoned_roboports) do
    ConcreteRoboport.mycelium(surfacedata.surface, {x = math.floor(roboport.position.x), y = math.floor(roboport.position.y)}, roboport.force)
  end

  ConcreteRoboport.purge_abandoned(surfacedata)
end

function ConcreteRoboport.purge_abandoned(surfacedata)
  log('#surfacedata.abandoned_roboports = ' .. table_size(surfacedata.abandoned_roboports))
  log('#surfacedata.abandoned_tiles = ' .. table_size(surfacedata.abandoned_tiles))

  for unit_number, tile in pairs(surfacedata.abandoned_tiles) do
    tile.destroy()
  end

  surfacedata.abandoned_roboports = {}
  surfacedata.abandoned_tiles = {}
end

function ConcreteRoboport.on_object_destroyed(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "concrete-roboport" then
      local surfacedata = storage.surfacedata[deathrattle.surface_index]
      local roboport = surfacedata.roboports[deathrattle.roboport_id]

      -- a new roboport can occupy this position before the deathrattle triggers
      if not surfacedata.roboport_at[roboport.tile_position_key].valid then
        surfacedata.roboport_at[roboport.tile_position_key] = nil
      end

      local network = surfacedata.networks[roboport.last_network_index]
      if network then
        ConcreteNetwork.sub_roboport(network, {unit_number = event.useful_id})
        ConcreteRoboport.purge_abandoned(surfacedata)
      end
    end
  end
end

return ConcreteRoboport
