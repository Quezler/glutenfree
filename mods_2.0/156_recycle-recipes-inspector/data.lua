require("shared")

-- do
--   local old_next = next
--   next = function(t, k)
--     if t == data.raw.recipe then
--       log("next() called directly on recipes!")
--     end
--     return old_next(t, k)
--   end
-- end

local mod_data = {
  type = "mod-data",
  name = mod_prefix .. "recycling-recipe-name-to-original-recipe-name",
  data = {},
}
data:extend{mod_data}

local recipe_being_recycled = nil
-- local item_being_recycled = nil

do
  setmetatable(data.raw.recipe, {
    __index = function(t, k)
      local info = debug.getinfo(2, "S")
      -- if info.source == "@__quality__/data-updates.lua" then
      --   log("going over recipes to recycle")
      --   log(serpent.line(info))
      --   log(k)
      -- end
      -- if info.source == "@__quality__/data-updates.lua" then -- self recycling?
      --   item_being_recycled = k:sub(1, -#"-recycling"-1)
      -- end 
      -- log(k .. " " .. info.source .. ":" .. info.linedefined)
      return rawget(t, k)
    end,
    __newindex = function(tbl, k, v)
      -- log('new recipe: ' .. k)
      -- log(recipe_being_recycled)
      -- log(item_being_recycled)

      if recipe_being_recycled then
        mod_data.data[k] = recipe_being_recycled
      end
      recipe_being_recycled = nil
      -- item_being_recycled = nil
      -- local info = debug.getinfo(2, "S")
      -- log(info.source .. ":" .. info.linedefined)
      -- print("Backtrace:\n" .. debug.traceback())
      -- for i = 1, math.huge do
      --   local name, value = debug.getlocal(2, i)
      --   if not name then break end
      --   print("arg:", name, "=", value)
      -- end
      rawset(tbl, k, v)
    end,
    __pairs = function(t)
    -- log("pairs() called on recipes")
    local info = debug.getinfo(2, "S")
    -- log(serpent.line(info))

    local k = nil
    while true do
      local recipe_name, recipe_prototype = next(t, k)
      if recipe_name == nil then break end
      -- log("pre-loop key: " .. tostring(recipe_name))
      k = recipe_name

      setmetatable(recipe_prototype, {
        __index = function(t, k)
          if k == "subgroup" then
            recipe_being_recycled = recipe_name -- allegedly
            -- log("accessed subgroup for " .. recipe_name)
          end
          return rawget(t, k)
        end,
      })
    end

    -- Option 1: Just pass through the real pairs iterator
    return next, t, nil
    end
    -- __pairs = function(t)
    --   log("pairs() called on recipes")
    --   log(debug.getinfo(2, "S").source)

    --   -- Wrapped iterator that logs each key as it's iterated
    --   local function iter(tbl, k)
    --     local nk, nv = next(tbl, k)
    --     if nk ~= nil then
    --       log("iterating key: " .. tostring(nk))
    --     else
    --       log("pairs() finished")
    --     end
    --     return nk, nv
    --   end

    --   -- Return the wrapped iterator
    --   return iter, t, nil
    -- end
  })
end

-- do
--   local __RECIPES = data.raw.recipe
--   data.raw.recipe = setmetatable({}, {
--     __index = function(t, k)
--       log(k)
--       local info = debug.getinfo(2, "S")
--       log(info.source .. ":" .. info.linedefined)
--       return __RECIPES[k]
--     end,
--   })
-- end

-- @burninsun on discord game up with this wizardry below which i have modified above:

-- do
--   local __DATA = data
--   local __CALLED = false
--   data = setmetatable({}, {
--     __index = function(t, k)
--       local called = debug.getinfo(2, "S").source == "=[C]"
--       log(debug.getinfo(2, "S").source .. ":" .. debug.getinfo(2, "S").linedefined)
--       if called and __CALLED then
--         log("DONE") -- <-- put finalizer code here
--       end
--       __CALLED = called
--       return __DATA[k]
--     end,
--   })
-- end
