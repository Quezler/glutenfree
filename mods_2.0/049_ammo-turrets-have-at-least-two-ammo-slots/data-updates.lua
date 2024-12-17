local min = 2

for _, ammo_turret in pairs(data.raw["ammo-turret"]) do
  if ammo_turret.inventory_size >= min then
    log(string.format("%s (%d)", ammo_turret.name, ammo_turret.inventory_size))
  else
    log(string.format("%s (%d -> %d)", ammo_turret.name, ammo_turret.inventory_size, min))
    ammo_turret.inventory_size = min
  end
end
