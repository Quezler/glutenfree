require("namespace")

local roboport = table.deepcopy(data.raw["roboport"]["roboport"])
roboport.name = "storage-roboport"
roboport.icon = mod_directory .. "/graphics/icons/storage-roboport.png"
roboport.base.layers[1].filename = mod_directory .. "/graphics/entity/storage-roboport/storage-roboport-base.png"
roboport.base_patch.filename = mod_directory .. "/graphics/entity/storage-roboport/storage-roboport-base-patch.png"
roboport.placeable_by = roboport.placeable_by or {item = "roboport", count = 1}
data:extend{roboport}
