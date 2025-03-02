local combinator = {}

-- LTN shipments are keyed in the "item,stone" & "fluid,water" format (aka: type comma name)
-- this function splits it at the comma, and returns the type and name seperately
function split(csv)
  local tmp = {}
  for string in string.gmatch(csv, "[^,]+") do
    table.insert(tmp, string)
  end
  return tmp[1], tmp[2]
end

-- convert the 'type,name = count' table into the format used by combinators:
-- `{{index = 1, signal = {type="virtual", name="signal-red"}, count = 1 }}`
function combinator.filters_from_shipment(shipment)
  local filters = {}

  for what, c in pairs(shipment) do
    local t, n = split(what)
    table.insert(filters, {
      value = {type = t, name = n, quality = "normal"},
      min = c,
    })
  end

  -- game.print(serpent.line(filters))
  return filters
end

return combinator
