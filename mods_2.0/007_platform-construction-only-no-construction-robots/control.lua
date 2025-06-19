
local blacklisted_names = require("scripts.blacklist")

local Handler = {}

script.on_init(function()
  storage.construction_robots = {}
  storage.lock = {}

  storage.tasks_at_tick = {}
end)

script.on_configuration_changed(function()
  --
end)

local function add_task(tick, task)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then
    tasks_at_tick[#tasks_at_tick + 1] = task
  else
    storage.tasks_at_tick[tick] = {task}
  end
end

function Handler.on_tick_robots(event)
  for unit_number, entity in pairs(storage.construction_robots) do
    if entity.valid then
      local robot_order_queue = entity.robot_order_queue
      for _, order in ipairs(robot_order_queue) do
        if order.target then -- target can sometimes be optional
          if order.type == defines.robot_order_type.construct then
            Handler.request_platform_animation_for(order.target)
          end
        end
      end
    else
      storage.construction_robots[unit_number] = nil
    end
  end
end

function Handler.request_platform_animation_for(entity)
  if entity.name ~= "entity-ghost" then return end
  if blacklisted_names[entity.ghost_name] then return end

  if storage.lock[entity.unit_number] then return end
  storage.lock[entity.unit_number] = true

  local response = remote.call("space-platform-entity-build-animation-lib", "legacy", entity)

  local tick = game.tick
  local surface = entity.surface

  add_task(response.all_scaffolding_up_at, {
    name = "destroy",
    entity = surface.create_entity{
      name = "ghost-being-constructed",
      force = "neutral",
      position = entity.position,
      create_build_effect_smoke = false,
      preserve_ghosts_and_corpses = true,
    }
  })

  add_task(response.all_scaffolding_down_at, {name = "unlock", unit_number = entity.unit_number})
end

local function do_tasks_at_tick(tick)
  local tasks_at_tick = storage.tasks_at_tick[tick]
  if tasks_at_tick then storage.tasks_at_tick[tick] = nil
    for _, task in ipairs(tasks_at_tick) do
      if task.name == "destroy" then
        task.entity.destroy()
      elseif task.name == "unlock" then
        storage.lock[task.unit_number] = nil
      end
    end
  end
end

script.on_event(defines.events.on_tick, function(event)
  Handler.on_tick_robots(event)

  do_tasks_at_tick(event.tick)
end)

script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id ~= "construction-robot-created" then return end

  local construction_robot = event.target_entity
  assert(construction_robot and construction_robot.name == "construction-robot")

  storage.construction_robots[construction_robot.unit_number] = construction_robot
end)
