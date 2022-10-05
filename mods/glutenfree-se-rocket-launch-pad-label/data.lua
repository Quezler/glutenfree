local prototype = table.deepcopy(data.raw['flying-text']['flying-text'])

prototype.name = 'hovering-text'
prototype.speed = 0
prototype.time_to_live = 4294967295 -- 2^32-1
prototype.text_alignment = 'center'

data:extend({prototype})
