local print_gui = {}

function print_gui.describe(gui_element)
  local node = {}

  node.type = gui_element.type
  node.name = gui_element.name
  node.style = gui_element.style.name
  node.caption = gui_element.caption
  node.children_names = gui_element.children_names

  node.children = {}
  for _, child in ipairs(gui_element.children) do
    table.insert(node.children, print_gui.describe(child))
  end

  if #node.children_names == 0 then node.children_names = nil end
  if #node.children == 0 then node.children = nil end

  if gui_element.tooltip then
    node.tooltip = gui_element.tooltip
  end

  if gui_element.type == "sprite-button" then
    node.sprite = gui_element.sprite
  end

  return node
end

function print_gui.serpent(gui_element)
  return serpent.block(print_gui.describe(gui_element))
end

function print_gui.path_to_caption(gui_element, locale_key, level)
  if gui_element.caption then
    if gui_element.caption[1] == locale_key then return level end
  end

  for i, child in ipairs(gui_element.children) do
    local path = print_gui.path_to_caption(child, locale_key, string.format(level .. '[%s]', i))
    if path then return path end
  end
end

return print_gui
