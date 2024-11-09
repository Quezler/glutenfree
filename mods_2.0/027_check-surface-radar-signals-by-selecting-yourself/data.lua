local mod_prefix = "csrsbsy-"

-- error(serpent.line(mods))

-- function simpleHash(input)
--   local hash_length = 10
--   local hash = {}

--   -- Generate hash by iterating through each character in the input
--   for i = 1, hash_length do
--       local char = string.byte(input, (i - 1) % #input + 1)
--       table.insert(hash, tostring((char + i) % 10)) -- Keep within digits 0-9
--   end

--   return table.concat(hash)
-- end

-- CRC32 Table
local crc32_table = {}
for i = 0, 255 do
    local crc = i
    for _ = 1, 8 do
        if crc % 2 == 1 then
            crc = (0xEDB88320 - math.floor(crc / 2)) % 0x100000000
        else
            crc = math.floor(crc / 2)
        end
    end
    crc32_table[i] = crc
end

-- CRC32 Function
local function crc32(str)
    local crc = 0xFFFFFFFF
    for i = 1, #str do
        local byte = string.byte(str, i)
        local index = (crc % 0x100) - byte
        -- Simulate the XOR with a positive modulus adjustment
        if index < 0 then
            index = index + 0x100
        end
        crc = (crc32_table[index] - math.floor(crc / 256)) % 0x100000000
    end
    return (0xFFFFFFFF - crc) % 0x100000000
end

-- Hash wrapper for your tables
local function tableToString(tbl)
    local elements = {}
    for k, v in pairs(tbl) do
        table.insert(elements, tostring(k) .. "=" .. tostring(v))
    end
    table.sort(elements)
    return table.concat(elements, ",")
end

local function hashTable(tbl)
    local str = tableToString(tbl)
    return string.format("%08X", crc32(str))
end

local proxy = table.deepcopy(data.raw["item-request-proxy"]["item-request-proxy"])
-- proxy.name = mod_prefix .. "item-request-proxy-" .. simpleHash(serpent.line(mods)) -- max 200
proxy.name = mod_prefix .. "item-request-proxy-1" .. hashTable(mods) -- max 200


local character = data.raw["character"]["character"]
proxy.selection_box = character.selection_box
proxy.collision_box = character.collision_box
proxy.selection_priority = (character.selection_priority or 50) - 1
proxy.minable.mining_time = 1000000

data:extend{proxy}

data:extend{{
  type = "electric-pole",
  name = mod_prefix .. "electric-pole",

  supply_area_distance = 0,
  connection_points = {},

  selection_box = {
    {character.selection_box[1][1] - 0.5, character.selection_box[1][2] - 0.5},
    {character.selection_box[2][1] + 0.5, character.selection_box[2][2] + 0.5},
  },
  collision_box = character.collision_box,
  selection_priority = (character.selection_priority or 50) + 1,

  flags = {"placeable-off-grid", "not-on-map"},
  collision_mask = {layers = {}},
}}

local radar = table.deepcopy(data.raw["item"]["radar"])
radar.name = mod_prefix .. "radar-barrel-2"
radar.hidden = true
-- radar.auto_recycle = false
data:extend{radar}
