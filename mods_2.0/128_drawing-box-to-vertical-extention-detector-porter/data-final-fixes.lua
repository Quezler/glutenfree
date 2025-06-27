local lines = {}

local function get_vertical_extention(prototype)
  local drawing_y = prototype.drawing_box.left_top and prototype.drawing_box.left_top.y or  prototype.drawing_box[1][2]
  local selection_y = prototype.selection_box and (prototype.selection_box.left_top and prototype.selection_box.left_top.y or  prototype.selection_box[1][2]) or 0

  return selection_y - drawing_y
end

for prototype_type, _ in pairs(defines.prototypes["entity"]) do
  for _, prototype in pairs(data.raw[prototype_type] or {}) do
    assert(prototype.drawing_box_vertical_extention == nil, prototype.name) -- typo detector
    if prototype.drawing_box then
      table.insert(lines, "")
      table.insert(lines, string.format('["%s"]["%s"]', prototype.type, prototype.name))
      table.insert(lines, "drawing_box = " .. serpent.line(prototype.drawing_box))
      table.insert(lines, "drawing_box_vertical_extension = " .. get_vertical_extention(prototype))
    end
  end
end

if #lines > 0 then
  table.insert(lines, 1, "these prototypes need updating:")
  table.insert(lines, "")
  error(table.concat(lines, "\n"))
end
