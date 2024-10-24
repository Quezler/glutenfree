local requesters = {
  "requester-chest",
  "aai-strongbox-requester",
  "aai-storehouse-requester",
  "aai-warehouse-requester",
}

local buffers = {
  "buffer-chest",
  "aai-strongbox-buffer",
  "aai-storehouse-buffer",
  "aai-warehouse-buffer",
}

for _, names in ipairs({requesters, buffers}) do
  for tier, name in ipairs(names) do
    data.raw["logistic-container"][name].trash_inventory_size = 20 -- i could do `* tier`, but beyond 30 it gets a scroll and that looks weird.
  end
end

