-- When this is true, the reactor will stop consuming fuel/energy when the temperature has reached the maximum.
data.raw['reactor']['nuclear-reactor'].scale_energy_usage = true

if mods['space-exploration'] then
  data.raw['reactor']['se-antimatter-reactor'].scale_energy_usage = true
end
