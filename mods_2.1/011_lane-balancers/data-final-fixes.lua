if mods["one-more-tier"] then
  lane_balancers_handle({
    prefix = "omt-",
    tech = "omt-logistics-4",
    previous_prefix = mods["space-age"] and "turbo-" or "express-",
    order = "e",
  })
end
