-- -- this creates some space between the name of the active research and the progress bar to render the bottles in.

-- for _, technology in pairs(data.raw['technology']) do
--   -- if technology.localised_name then
--   --   log(serpent.line(technology.localised_name))
--   -- end

--   if not technology.localised_name then
--     technology.localised_name = {"technology-name." .. string.gsub(technology.name, "-(%d+)$", "")}
--     -- if string.match(technology.name, pattern)
--   end

--   if technology.localised_name[1] ~= "" then
--     technology.localised_name = {"", technology.localised_name}
--   end

--   table.insert(technology.localised_name, "\n")

--   -- technology.localised_name = {"", {"technology-name." .. technology.name}, "\n", "foobar"}
-- end
