local mod_prefix = 'glutenfree-circuit-network-events-'

--

local inserter = table.deepcopy(data.raw['inserter']['inserter'])
inserter.name = mod_prefix .. 'inserter'
inserter.energy_source = {type = 'void'}

-- if this number is too high the inserter will pick the item up before realizing the circuit condition prevents it.
-- might need some extra finetuning, 3 or higher causes problems for sure. (so somewhere between 0.25 and up to 0.3)
-- also, i haven't tested the delay in ticks (if any) between the tick being sent & the inserter having picked it up.
inserter.extension_speed = 0.25 

data:extend({inserter})
