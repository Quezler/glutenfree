-- in case a mod deepcopies the lamp before our mod runs or just has the prototype copy pasted we just override any default matching ones.

for _, lamp in pairs(data.raw["lamp"]) do
  if lamp.light and lamp.light.color then
    if lamp.light.color.r == 1 and lamp.light.color.g == 1 and lamp.light.color.b == 0.75 then
      lamp.light.color = nil
    end
  end
end
