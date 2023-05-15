local util = require('util')

--

local Handler = {}

function Handler.on_init(event)
  global.flushed_by_force = {} -- currently merging forces is not supported, nor is this cleaned up if a force gets deleted, either case is rather abnormal during an SE run.
end

local entity_whitelist = util.list_to_map({
  'se-spaceship-rocket-booster-tank',
  'se-spaceship-ion-booster-tank',
  'se-spaceship-antimatter-booster-tank',
})

local fluid_whitelist = util.list_to_map({
  'se-liquid-rocket-fuel',
  'se-ion-stream',
  'se-antimatter-stream',
})

local hardcoded_canisters = {
  ['se-liquid-rocket-fuel'] = {input = 'empty-barrel',         amount =  100, output = 'se-liquid-rocket-fuel-barrel'}, -- not turned into solid rocket fuel due to productivity loops
  ['se-ion-stream']         = {input = 'se-magnetic-canister', amount = 1000, output = 'se-ion-canister'             },
  ['se-antimatter-stream']  = {input = 'se-magnetic-canister', amount = 1000, output = 'se-antimatter-canister'      }, -- the recipe requires thermofluid, but this mod ignores it :)
}

function Handler.on_player_flushed_fluid(event)
  -- the flush button has to be pressed inside a whitelisted entity's gui
  if not entity_whitelist[event.entity.name] then return end
  if not fluid_whitelist[event.fluid] then return end

  local player = game.get_player(event.player_index)

  if not global.flushed_by_force[player.force.index] then
    global.flushed_by_force[player.force.index] = {}
  end

  if not global.flushed_by_force[player.force.index][event.fluid] then
    global.flushed_by_force[player.force.index][event.fluid] = 0
  end

  global.flushed_by_force[player.force.index][event.fluid] = global.flushed_by_force[player.force.index][event.fluid] + event.amount
  -- allright, now we have the total amount of that fluid flushed by that force, including amounts that weren't enough to barrel yet

  local recipe = hardcoded_canisters[event.fluid]

  local logistic_networks = event.entity.surface.find_logistic_networks_by_construction_area(event.entity.position, event.entity.force)
  for _, logistic_network in ipairs(logistic_networks) do
    local canisters_needed = math.floor(global.flushed_by_force[player.force.index][event.fluid] / recipe.amount)
    local canisters_available = logistic_network.remove_item({name = recipe.input, count = canisters_needed})

    -- assume spill_item_stack managed to spill every canister, we're not gonna put unused canisters back into the logistic network

    if canisters_available > 0 then
      event.entity.surface.spill_item_stack(event.entity.position, {name = recipe.output, count = canisters_available}, false, event.entity.force, false)
      global.flushed_by_force[player.force.index][event.fluid] = global.flushed_by_force[player.force.index][event.fluid] - (canisters_available * recipe.amount)
    end
  end
end

--

script.on_init(Handler.on_init)

script.on_event(defines.events.on_player_flushed_fluid, Handler.on_player_flushed_fluid)

commands.add_command("se-cheepskate-booster-tank", "Show my force's data.", function(event)
  local player = game.get_player(event.player_index)

  game.print(serpent.block(global.flushed_by_force[player.force.index]))
end)
