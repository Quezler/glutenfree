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

local function hashString(str)
    return string.format("%08X", crc32(str))
end

-- local function hashTable(tbl)
--     return hashString(tableToString(tbl))
-- end

return hashString
