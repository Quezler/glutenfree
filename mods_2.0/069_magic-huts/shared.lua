local source = debug.getinfo(1, "S").source

mod_name = source:sub(4, source:find("/") - 3)
mod_prefix = mod_name .. "--"
mod_directory = "__" .. mod_name .. "__"

function get_entity_type(entity)
  return entity.type == "entity-ghost" and entity.ghost_type or entity.type
end

function get_entity_name(entity)
  return entity.type == "entity-ghost" and entity.ghost_name or entity.name
end

---@param value any
---@param options? serpent.options
---@return string
function serpent_line(value, options)
  _options = {sortkeys = false}
  for k, v in pairs(options or {}) do _options[k] = v end
  return serpent.line(value, _options)
end

---@param value any
---@param options? serpent.options
---@return string
function serpent_block(value, options)
  _options = {sortkeys = false}
  for k, v in pairs(options or {}) do _options[k] = v end
  return serpent.block(value, _options)
end
