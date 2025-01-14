local Handler = {}

script.on_init(function()
  storage.surface = game.planets["greedy-inserter"].create_surface()
  storage.surface.generate_with_lab_tiles = true

  storage.next_x_offset = 0
  storage.greedy_inserters = {}

  storage.deathrattles = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local function tick_struct(struct)
  struct.itemstack_burner.set_stack({name = "greedy-inserter--compiltron"})
  storage.deathrattles[script.register_on_object_destroyed(struct.itemstack_burner.item)] = {struct.id, "fuel"}

  if struct.itemstack_hand.valid_for_read then
    struct.inserter.drop_target = nil
  else
    struct.inserter.drop_target = struct.container
  end
end

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination -- todo: handle cloning

  local struct = new_struct(storage.greedy_inserters, {
    id = entity.unit_number,

    inserter = entity,
    container = nil,

    itemstack_hand = entity.held_stack,
    itemstack_burner = entity.get_inventory(defines.inventory.fuel)[1],
  })

  struct.container = entity.surface.create_entity{
    name = "greedy-inserter--container",
    force = "neutral",
    position = entity.drop_position,
  }
  struct.container.destructible = false

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct.id, "inserter"}
  tick_struct(struct)
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, Handler.on_created_entity, {
    {filter = "name", name = "greedy-inserter"},
  })
end

local function purge_struct(struct)
  storage.greedy_inserters[struct.id] = nil
  struct.container.destroy()
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    game.print(event.tick .. serpent.line(deathrattle))

    local struct = storage.greedy_inserters[deathrattle[1]]
    if struct then
      if deathrattle[2] == "fuel" then
        tick_struct(struct)
      elseif deathrattle[2] == "inserter" then
        purge_struct(struct)
      else
        error(serpent.block(deathrattle))
      end
    end
  end
end)

local function on_player_rotated_or_flipped_entity(event)
  local entity = event.entity

  if entity.name == "greedy-inserter" then
    local struct = storage.greedy_inserters[entity.unit_number]
    struct.container.teleport(entity.drop_position)
    tick_struct(struct)
  end
end

-- there is no way to listen for "allow_custom_vectors", but the player can just rotate them.
script.on_event(defines.events.on_player_rotated_entity, on_player_rotated_or_flipped_entity)
script.on_event(defines.events.on_player_flipped_entity, on_player_rotated_or_flipped_entity)
