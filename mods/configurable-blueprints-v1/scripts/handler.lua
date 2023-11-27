local util = require('util')

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.created_entity or event.entity
  assert(entity.name == 'entity-ghost')

  if Handler.entity_type_is_excluded[entity.ghost_type] then return end
  game.print(entity.ghost_name)

  entity.revive{raise_revive = true}
end

Handler.entity_type_is_whitelisted = util.list_to_map(require('scripts.prototypes'))

return Handler
