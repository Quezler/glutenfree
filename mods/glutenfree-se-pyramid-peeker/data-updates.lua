-- local modules = {'productivity-module-9', 'speed-module-9', 'effectivity-module-9'}
-- for _, module in ipairs(modules) do
--   print(serpent.block( module ))
--   print(serpent.block( data.raw['module'] ))
--   data:extend({{
--     type = 'item',
--     name = 'se-cartouche-chest-with-one-' .. module,
--     stack_size = 50,
--     icons = {
--       {
--         icon = data.raw['container']['se-cartouche-chest'].icon,
--         icon_size = data.raw['container']['se-cartouche-chest'].icon_size,
--       },
--       {
--         icon = data.raw['module'][module].icon,
--         icon_size = data.raw['module'][module].icon_size,
--         scale = 0.25,
--       }
--     }
--   }})
-- end
