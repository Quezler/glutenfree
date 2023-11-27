local util = require('util')

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity
  assert(entity.name == 'entity-ghost')

  if not Handler.entity_type_is_whitelisted[entity.ghost_type] then return end
  game.print(entity.ghost_name)

  -- local _, entity, _ = entity.revive{raise_revive = true}

  -- local prototype = entity.prototype

  -- rendering.draw_sprite{
  --   sprite = "utility/not_enough_repair_packs_icon",
  --   surface = entity.surface,
  --   target = entity,
  --   target_offset = prototype.alert_icon_shift,
  --   x_scale = prototype.alert_icon_scale,
  --   y_scale = prototype.alert_icon_scale,
  -- }
end

Handler.entity_type_is_whitelisted = util.list_to_map(require('scripts.prototypes'))

return Handler
