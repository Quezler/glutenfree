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

local drill = table.deepcopy(data.raw['mining-drill']['electric-mining-drill'])
drill.name = mod_prefix .. 'drill'

drill.collision_box = {{ -0.4, -0.4}, {0.4, 0.4}}
drill.selection_box = {{ -0.5, -0.5}, {0.5, 0.5}}
drill.input_fluid_box = nil

drill.resource_searching_radius = 0.49

data:extend({drill})
