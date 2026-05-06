local mod = {}

mod.mod_data = prototypes.mod_data["microtransactions"].data --[[@as ModData]]

-- mod.

script.on_init(function()
  local visible_when_disabled = {}

  for _, offer in pairs(mod.mod_data.offers) do
    for _, technology_name in pairs(offer.technologies or {}) do
      assert(prototypes.technology[technology_name], technology_name)
      visible_when_disabled[technology_name] = true
    end
  end

  log(serpent.block(visible_when_disabled))

  for _, force in pairs(game.forces) do
    for technology_name, technology in pairs(force.technologies) do
      if visible_when_disabled[technology_name] then
        technology.visible_when_disabled = true
        technology.enabled = false
      end
    end
  end
end)
