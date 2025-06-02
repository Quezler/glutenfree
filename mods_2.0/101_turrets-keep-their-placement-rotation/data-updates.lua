local function handle_turret(turret)
  -- log(turret.name)
  -- log(turret.folding_animation ~= nil)

  if turret.turret_base_has_direction == true then return end
  turret.turret_base_has_direction = true -- the magic sauce

  log(string.format('["%s"]["%s"]', turret.type, turret.name))

  if turret.circuit_connector == nil then return end
  if #turret.circuit_connector ~= 1 then return end

  turret.circuit_connector = {
    turret.circuit_connector,
    turret.circuit_connector,
    turret.circuit_connector,
    turret.circuit_connector,
  }
end

for _, ammo_turret in pairs(data.raw["ammo-turret"]) do
  handle_turret(ammo_turret)
end

for _, electric_turret in pairs(data.raw["electric-turret"]) do
  handle_turret(electric_turret)
end
