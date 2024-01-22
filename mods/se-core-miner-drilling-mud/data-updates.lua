local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local to_extend = {}

for _, resource in pairs(data.raw['resource']) do
  if starts_with(resource.name, 'se-core-fragment-') == true then
    if ends_with(resource.name, '-sealed') == false then
      log(resource.name)

      local clone = table.deepcopy(resource)
      clone.name = clone.name .. '-drilling-mud'
      clone.selection_priority = (clone.selection_priority or 50) - 1
      clone.minable.required_fluid = 'se-core-miner-drill-drilling-mud'
      clone.minable.fluid_amount = 1
      resource.minable.required_fluid = 'se-core-miner-drill-drilling-mud'
      resource.minable.fluid_amount = 0
      
      table.insert(to_extend, clone)
    end
  end
end

data:extend(to_extend)

-- error('done')
