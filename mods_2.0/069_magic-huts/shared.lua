local short_src = debug.getinfo(1, 'S').short_src

mod_name = short_src:sub(3, short_src:find("/") - 3)
mod_prefix = mod_name .. "--"
mod_directory = "__" .. mod_name .. "__"

---@param value any
---@param options? serpent.options
---@return string
function serpent_line(value, options)
  _options = {sortKeys = false}
  for k, v in pairs(options or {}) do _options[k] = v end
  return serpent.line(value, _options)
end

---@param value any
---@param options? serpent.options
---@return string
function serpent_block(value, options)
  _options = {sortKeys = false}
  for k, v in pairs(options or {}) do _options[k] = v end
  return serpent.block(value, _options)
end
