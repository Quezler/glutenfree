local source = debug.getinfo(1, "S").source

mod_name = source:sub(4, source:find("/") - 3)
mod_prefix = mod_name .. "--"
mod_directory = "__" .. mod_name .. "__"

return {
  get_item_prototypes = function ()
    local prototypes = {}
    for type_name in pairs(defines.prototypes.item) do
      for _, item in pairs(data.raw[type_name] or {}) do
        prototypes[item.name] = item
      end
    end
    return prototypes
  end,
  get_entity_prototypes = function ()
    local prototypes = {}
    for type_name in pairs(defines.prototypes.entity) do
      for _, entity in pairs(data.raw[type_name] or {}) do
        prototypes[entity.name] = entity
      end
    end
    return prototypes
  end,
}
