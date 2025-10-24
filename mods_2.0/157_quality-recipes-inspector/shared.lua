local source = debug.getinfo(1, "S").source -- @__the-mod-name__/shared.lua

mod_name = source:sub(4, source:find("/") - 3)
mod_prefix = mod_name .. "--"
mod_directory = "__" .. mod_name .. "__"

-- --- @param entity LuaEntity
-- --- @return string
-- function get_entity_type(entity)
--   return entity.type == "entity-ghost" and entity.ghost_type or entity.type
-- end

-- --- @param entity LuaEntity
-- --- @return string
-- function get_entity_name(entity)
--   return entity.type == "entity-ghost" and entity.ghost_name or entity.name
-- end

-- --- @param entity LuaEntity
-- --- @return LuaEntityPrototype|LuaTilePrototype
-- function get_entity_prototype(entity)
--   return entity.type == "entity-ghost" and entity.ghost_prototype or entity.prototype
-- end

-- local function merge(a, b) for k, v in pairs(b or {}) do a[k] = v end return a end
-- local serpent_line = serpent.line
-- local serpent_block = serpent.block

-- --- @param value any
-- --- @param options? serpent.options
-- --- @return string
-- --- @diagnostic disable-next-line: duplicate-set-field
-- function serpent.line(value, options)
--   return serpent_line(value, merge({sortkeys = false}, options))
-- end

-- --- @param value any
-- --- @param options? serpent.options
-- --- @return string
-- --- @diagnostic disable-next-line: duplicate-set-field
-- function serpent.block(value, options)
--   return serpent_block(value, merge({sortkeys = false}, options))
-- end
