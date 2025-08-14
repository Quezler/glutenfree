local mod = {}

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}

  storage.combinators_for_player = {}
end)

script.on_configuration_changed(function()
  --
end)

function new_struct(table, struct)
  assert(struct.id)
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

mod.on_created_entity_filters = {
  {filter = "name", name = "hand-held-combinator"},
}

local function ensure_2_sections(sections)
  while 2 > sections.sections_count do
    sections.add_section()
  end
end

local function unregister_struct_from_combinators_for_player(struct)
  if struct.player_index then
    storage.combinators_for_player[struct.player_index][struct.id] = nil

    -- if the player has no more combinators we'll just remove the table too
    if next(storage.combinators_for_player[struct.player_index]) == nil then
      storage.combinators_for_player[struct.player_index] = nil
    end
  end
end

local function struct_set_player_index(struct, player_index)
  unregister_struct_from_combinators_for_player(struct)

  if player_index then
    storage.combinators_for_player[player_index] = storage.combinators_for_player[player_index] or {}
    storage.combinators_for_player[player_index][struct.id] = true
    local player = game.get_player(player_index)
    if player then
      struct.text.text = player.name
    else
      struct.text.text = "x"
    end
  end

  struct.sections.sections[1].set_slot(1, {
    value = {type = "entity", name = "character", quality = "normal"},
    min = player_index or 0,
  })
  struct.sections.sections[2].clear_slot(1)
  if player_index and game.get_player(player_index) then
    mod.on_player_cursor_stack_changed({player_index = player_index})
  end

  struct.player_index = player_index
end

mod.on_created_entity = function(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,

    sections = entity.get_logistic_sections(),
    text = nil,
  })

  ensure_2_sections(struct.sections)
  local player_index = nil

  local first_filter = struct.sections.sections[1].get_slot(1)
  if first_filter.value and first_filter.value.type == "entity" and first_filter.value.name == "character" then
    if first_filter.min >= 1 and 65536 >= first_filter.min then
      player_index = first_filter.min
    end
  else
    -- override active only if the character filter was not present
    struct.sections.sections[1].active = false
  end

  struct.text = rendering.draw_text{
    text = "?",
    surface = entity.surface,
    target = {entity = entity, offset = {0, -0.45}},
    color = {1, 1, 1},
    only_in_alt_mode = true,
    alignment = "center",
    scale = 0.5,
  }

  if player_index == nil and event.player_index then
    player_index = event.player_index or (entity.last_user and entity.last_user.player_index)
  end
  struct_set_player_index(struct, player_index)

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {struct_id = struct.id}
end

for _, event in ipairs({
  defines.events.on_built_entity,
  defines.events.on_robot_built_entity,
  defines.events.on_space_platform_built_entity,
  defines.events.script_raised_built,
  defines.events.script_raised_revive,
  defines.events.on_entity_cloned,
}) do
  script.on_event(event, mod.on_created_entity, mod.on_created_entity_filters)
end

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil
    local struct = storage.structs[deathrattle.struct_id]
    if struct then storage.structs[deathrattle.struct_id] = nil
      unregister_struct_from_combinators_for_player(struct)
    end
  end
end)

local function update_combinators(combinators, filter)
  for struct_id, _ in pairs(combinators) do
    local sections = storage.structs[struct_id].sections
    if sections.valid then
      ensure_2_sections(sections)
      if filter then
        sections.sections[2].set_slot(1, filter)
      else
        sections.sections[2].clear_slot(1)
      end
    else
      log(string.format("struct #%d didn't deathrattle yet.", struct_id))
    end
  end
end

mod.on_player_cursor_stack_changed = function(event)
  local combinators_for_player = storage.combinators_for_player[event.player_index]
  if not combinators_for_player then return end

  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
  if player.cursor_stack and player.cursor_stack.valid_for_read then
    update_combinators(combinators_for_player, {
      value = {type = "item", name = player.cursor_stack.name, quality = player.cursor_stack.quality.name},
      min = player.cursor_stack.count,
    })
  elseif player.cursor_ghost then
    update_combinators(combinators_for_player, {
      value = {type = "item", name = player.cursor_ghost.name.name, quality = player.cursor_ghost.quality.name},
      min = -1,
    })
  else
    update_combinators(combinators_for_player, nil)
  end
end

script.on_event(defines.events.on_player_cursor_stack_changed, mod.on_player_cursor_stack_changed)
