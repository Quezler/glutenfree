flib = require('__flib__.data-util')

local combinator = flib.copy_prototype(data.raw['constant-combinator']['logistic-train-stop-lamp-control'], 'red-signal-on-backer-name-combinator')
combinator.draw_circuit_wires = false
combinator.item_slot_count = 1

data:extend({combinator})
