local utility_sprites = data.raw["utility-sprites"]["default"]
if utility_sprites.filter_blacklist.filename == "__core__/graphics/filter-blacklist.png" then
  utility_sprites.filter_blacklist = util.empty_sprite()
end
