local source = debug.getinfo(1, "S").source -- @__the-mod-name__/shared.lua

mod_name = source:sub(4, source:find("/") - 3)
mod_prefix = mod_name .. "--"
mod_directory = "__" .. mod_name .. "__"
