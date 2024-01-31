local cartouche = data.raw['container']['se-cartouche-chest']
local arcolink = data.raw['linked-container']['se-linked-container']
local arcolink_item = data.raw['item']['se-linked-container']

cartouche.minable = table.deepcopy(arcolink.minable)
cartouche.minable.mining_time = cartouche.minable.mining_time * 4

arcolink.localised_name = {"entity-name." .. cartouche.name}
arcolink.picture = cartouche.picture

-- arcolink.icon = cartouche.icon
-- arcolink.icon_size = cartouche.icon_size
-- arcolink.icon_mipmaps = cartouche.icon_mipmaps

-- arcolink_item.icon = cartouche.icon
-- arcolink_item.icon_size = cartouche.icon_size
-- arcolink_item.icon_mipmaps = cartouche.icon_mipmaps

local icons = {
  {
    icon = "__core__/graphics/empty.png",
    icon_size = 1,
    icon_mipmaps = 1,
  },
  {
    icon = cartouche.icon,
    icon_size = cartouche.icon_size,
    icon_mipmaps = cartouche.icon_mipmaps,
    scale = 0.46,
  }
}

arcolink.icons = icons
arcolink_item.icons = icons

-- cartouche.localised_description = {"entity-description." .. arcolink.description}
-- arcolink.localised_description = {"", "foo"}
-- arcolink_item.localised_description = {"", "bar"}

data.raw['technology']['se-linked-container'].hidden = true

cartouche.localised_description = {"", {"entity-description." .. arcolink.name}, " Pick it up to get started."}
