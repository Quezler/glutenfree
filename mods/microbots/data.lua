local icr = table.deepcopy(data.raw['construction-robot']['construction-robot'])

icr.placeable_by = {item = icr.name, count = 1}
icr.name = 'invisible-' .. icr.name
-- icr.idle = nil
-- icr.in_motion = nil
-- icr.shadow_idle = nil
-- icr.shadow_in_motion = nil

data:extend({icr})
