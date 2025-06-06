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
    whitelisted_tiles[tile.name] = {tile.name}
    if tile.frozen_variant then
      table.insert(whitelisted_tiles[tile.name], tile.frozen_variant.name)
    end
    if tile.thawed_variant then
      table.insert(whitelisted_tiles[tile.name], tile.thawed_variant.name)
    end
  end
end
log("whitelisted_tiles: " .. serpent.line(whitelisted_tiles))

function ConcreteRoboport.on_init()
  storage.surfacedata = {}
  mod.refresh_surfacedata()

  storage.invalid = game.create_inventory(0)
  storage.invalid.destroy()

  storage.next_network_index = 1

  storage.deathrattles = {}
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

      roboports = {}, -- {unit_number = struct}
      roboport_at = {}, -- {tile_position_to_key = LuaEntity}

      abandoned_roboports = {}, -- {unit_number = LuaEntity}
      abandoned_tiles = {}, -- {unit_number = LuaEntity}

      roboport_tile_to_network_id = {},
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
  local tile_group = whitelisted_tiles[origin_tile.name]
  if not tile_group then
    return
  end

  local surfacedata = storage.surfacedata[surface.index]

  ---@type TilePosition[]
  local tiles = surface.get_connected_tiles(position, tile_group, true)
  local roboports = {}

  for _, tile_position in ipairs(tiles) do
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
    surfacedata.roboport_tile_to_network_id[roboport_tile.unit_number] = network.index

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
---@return LuaEntity
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
    assert(tile)
    tile.destructible = false
    storage.deathrattles[script.register_on_object_destroyed(tile)] = {
      name = "concrete-roboport--tile",
      surface_index = tile.surface.index,
    }
    tiles[key] = tile
  end

  return tile
end

function ConcreteRoboport.on_built_tile(event)
  local surfacedata = storage.surfacedata[event.surface_index]
  local networks = surfacedata.networks

  local encroached = {}

  for _, network in pairs(networks) do
    local advanced_tiles = {{network.min_x - 1, network.min_y - 1}, {network.max_x + 1, network.max_y + 1}}
    for _, tile in ipairs(event.tiles) do
      -- one of the new tiles is touching the selection box of the network
      if position_inside_area(tile.position, advanced_tiles) then
        log(string.format("encroached on network #%d", network.index))
        encroached[network.index] = network
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
    if roboport.valid then
      ConcreteRoboport.mycelium(surfacedata.surface, {x = math.floor(roboport.position.x), y = math.floor(roboport.position.y)}, roboport.force)
    end
  end

  ConcreteRoboport.purge_abandoned(surfacedata)
end

function ConcreteRoboport.purge_abandoned(surfacedata)
  -- log('#surfacedata.abandoned_roboports = ' .. table_size(surfacedata.abandoned_roboports))
  -- log('#surfacedata.abandoned_tiles = ' .. table_size(surfacedata.abandoned_tiles))

  for unit_number, tile in pairs(surfacedata.abandoned_tiles) do
    tile.destroy()
  end

  surfacedata.abandoned_roboports = {}
  surfacedata.abandoned_tiles = {}
end

function ConcreteRoboport.on_object_destroyed(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    if deathrattle.name == "concrete-roboport--tile" then
      local surfacedata = storage.surfacedata[deathrattle.surface_index]
      surfacedata.roboport_tile_to_network_id[event.useful_id] = nil
    elseif deathrattle.name == "concrete-roboport" then
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
