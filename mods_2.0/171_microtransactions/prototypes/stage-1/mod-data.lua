---@class ModData
  ---@field offers table<string, OfferData>
  ---\@field visible_when_disabled table<string, true>

---@class OfferData
  ---@field name string
  ---@field technologies? string[]
  ---@field price string

data:extend{
  {
    type = "mod-data",
    name = "microtransactions",
    data = {
      offers = {},
    },
  },
}

microtransactions.mod_data = data.raw["mod-data"]["microtransactions"].data

---@param offer OfferData
microtransactions.add_offer = function(offer)
  microtransactions.mod_data.offers[offer.name] = offer
end
