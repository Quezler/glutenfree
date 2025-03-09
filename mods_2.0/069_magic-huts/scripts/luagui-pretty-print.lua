LuaGuiPrettyPrint = {}

function LuaGuiPrettyPrint.path_to_caption(element, locale_key, breadcrumbs)
  if element.caption then
    if element.caption[1] == locale_key then return breadcrumbs end
    if element.caption[1] == "" then -- glued together, check the first
      if element.caption[2][1] == locale_key then return breadcrumbs end
    end
  end

  for i, child in ipairs(element.children) do
    local breadcrumb = string.format(".children[%d]", i)
    if child.name ~= "" then breadcrumb = string.format("[%s]", child.name) end

    local path = LuaGuiPrettyPrint.path_to_caption(child, locale_key, breadcrumbs .. breadcrumb)
    if path then return path end
  end
end

function LuaGuiPrettyPrint.path_to_tag(element, key, value, breadcrumbs)
  if element.tags then
    if element.tags[key] == value then return breadcrumbs end
  end

  for i, child in ipairs(element.children) do
    local breadcrumb = string.format(".children[%d]", i)
    if child.name ~= "" then breadcrumb = string.format("[%s]", child.name) end

    local path = LuaGuiPrettyPrint.path_to_tag(child, key, value, breadcrumbs .. breadcrumb)
    if path then return path end
  end
end

function LuaGuiPrettyPrint.dump(element, silent)
  local node = {
    type = element.type,
    name = element.name,
    style = element.style and element.style.name,
    caption = element.caption,
    children_count = #element.children,
  }

  if element.tooltip then
    node.tooltip = element.tooltip
  end

  node.children = {}
  for _, child in ipairs(element.children) do
    table.insert(node.children, LuaGuiPrettyPrint.dump(child, true))
  end

  if not silent then
    log(serpent.block(node, {sortkeys = false}))
  end

  return node
end

function LuaGuiPrettyPrint.path_to_element(element, breadcrumbs)
  breadcrumbs = breadcrumbs or ""

  local breadcrumb = nil
  if element.name ~= "" then
    breadcrumb = "[\"" .. element.name .. "\"]"
  else
    breadcrumb = ".children[" .. element.get_index_in_parent() .. "]"
  end

  local parent = element.parent
  if parent then
    return LuaGuiPrettyPrint.path_to_element(parent, breadcrumb .. breadcrumbs)
  else
    return "player.gui." .. element.name .. breadcrumbs
  end
end
