local function starts_with(str, start)
  return str:sub(1, #start) == start
end

local function ends_with(str, ending)
  return ending == "" or str:sub(-#ending) == ending
end

local to_extend = {}

for _, resource in pairs(data.raw['resource']) do
  if starts_with(resource.name, 'se-core-fragment-') == true then
    log(resource.name)

    resource.minable.required_fluid = 'se-core-miner-drill-drilling-mud'
    resource.minable.fluid_amount = 10
  end
end

