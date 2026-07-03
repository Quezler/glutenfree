-- base-data-updates.lua in __space-age__ (unlike the name suggests) runs at the start of that mod's data stage,
-- therefore we load the mod as unordered dependency (~) so we can grab the 3 types it modifies and restore them.

-- ofc if other mods modify stuff in their data-updates that runs in order before this mod it'll get lost.

local default_import_location = data.raw['capsule']['cliff-explosives'].default_import_location
if default_import_location and default_import_location == "vulcanus" then
  error('sanity check failed, cliff explosives got modified too soon.')
end

id_like_cliff_explosives_on_nauvis_please = {
  capsule    = table.deepcopy(data.raw['capsule'   ]['cliff-explosives']),
  recipe     = table.deepcopy(data.raw['recipe'    ]['cliff-explosives']),
  technology = table.deepcopy(data.raw['technology']['cliff-explosives']),
}
