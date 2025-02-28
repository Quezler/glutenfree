local short_src = debug.getinfo(1, 'S').short_src

mod_name = short_src:sub(3, short_src:find("/") - 3)
mod_prefix = mod_name .. "--"
mod_directory = "__" .. mod_name .. "__"

function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end
