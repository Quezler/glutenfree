local handler = require("scripts.juicebox")

script.on_init(handler.on_init)

script.on_event(defines.events.on_built_entity, handler.on_created_entity, {
  {filter = "name", name = "se-spaceship-console"},
})

script.on_event(defines.events.on_space_platform_built_entity, handler.on_created_entity, {
  {filter = "name", name = "se-spaceship-console"},
})

script.on_event(defines.events.on_robot_built_entity, handler.on_created_entity, {
  {filter = "name", name = "se-spaceship-console"},
})

script.on_event(defines.events.script_raised_built, handler.on_created_entity, {
  {filter = "name", name = "se-spaceship-console"},
})

script.on_event(defines.events.script_raised_revive, handler.on_created_entity, {
  {filter = "name", name = "se-spaceship-console"},
})

script.on_event(defines.events.on_object_destroyed, handler.on_object_destroyed)

script.on_event(defines.events.on_entity_cloned, handler.on_entity_cloned, {
  {filter = "name", name = "se-spaceship-console"},
  {filter = "name", name = "glutenfree-se-spaceship-juicebox-storage"},
  {filter = "name", name = "glutenfree-se-spaceship-juicebox-active-provider"},
})
