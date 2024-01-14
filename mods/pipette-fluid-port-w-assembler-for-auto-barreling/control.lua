local bounding_box = require("__flib__.bounding-box")
local flib_direction = require("__flib__/direction")

local function on_selected_entity_changed_whilst_holding(player, prototype)
  assert(prototype.object_name == 'LuaItemPrototype')

  if prototype.place_result == nil then return end
  if prototype.place_result.type ~= "assembling-machine" then return end
  if prototype.place_result.crafting_categories['crafting-with-fluid'] == nil then return end -- assume all barrel recipes are in here

  if player.selected == nil then return end
  local entity = player.selected

  if #entity.fluidbox == 0 then return end

  local playerdata = global.playerdata[player.index]
  if not playerdata then
    playerdata = {
      to_destroy = {}
    }
    global.playerdata[player.index] = playerdata
  end

  for i = 1, #entity.fluidbox do
    local fluid_name = entity.fluidbox.get_locked_fluid(i)
    if global.barrelable_fluids[fluid_name] == nil then goto continue end

    for _, pipe_connection in ipairs(entity.fluidbox.get_pipe_connections(i)) do
      local highlighter = entity.surface.create_entity{
        name = 'highlight-box',
        position = pipe_connection.position,
        bounding_box = {
          {pipe_connection.position.x -0.5, pipe_connection.position.y -0.5},
          {pipe_connection.position.x +0.5, pipe_connection.position.y +0.5}
        },
        box_type = "train-visualization",
        render_player_index = player.index,
      }

      local selectable = entity.surface.create_entity{
        name = 'pipe-connection',
        position = pipe_connection.position,
      }

      table.insert(playerdata.to_destroy, highlighter)
      table.insert(playerdata.to_destroy, selectable)

      global.pipe_connections[script.register_on_entity_destroyed(selectable)] = {
        highlighter = highlighter,
        selectable = selectable,
        item_name = prototype.place_result.name,
        fluid_name = fluid_name,
        drain = pipe_connection.flow_direction == "output" and true or false, -- expect "input" and "input-output" to want fluids
        direction = flib_direction.from_positions(pipe_connection.position, pipe_connection.target_position, true),
      }
    end

    ::continue::
  end
end

script.on_event(defines.events.on_selected_entity_changed, function(event)
  local player = game.get_player(event.player_index)

  local selected = player.selected
  if selected == nil and global.playerdata[player.index] then
    for _, entity in pairs(global.playerdata[player.index].to_destroy) do
      entity.destroy()
    end
    global.playerdata[player.index].to_destroy = {}
  end

  -- player is a spectator
  if not player.cursor_stack then return end

  if player.cursor_stack.valid_for_read then
    on_selected_entity_changed_whilst_holding(player, player.cursor_stack.prototype)
  elseif player.cursor_ghost then
    on_selected_entity_changed_whilst_holding(player, player.cursor_ghost)
  else
    -- empty hand
  end
end)

local function empty_barrel_recipe_name(fluid_name)
  return 'empty-' .. fluid_name .. '-barrel'
end

local function fill_barrel_recipe_name(fluid_name)
  return 'fill-' .. fluid_name .. '-barrel'
end

local function on_configuration_changed()
  -- global.pipe_connections = {}
  -- global.playerdata = {}
  global.barrelable_fluids = {}
  
  for _, fluid_prototype in pairs(game.fluid_prototypes) do
    -- todo: check for barreling and unbarreling recipes through prototypes instead of assuming they're named a certain was as per the 2 functions above.
    if game.recipe_prototypes[fill_barrel_recipe_name(fluid_prototype.name)] and game.recipe_prototypes[empty_barrel_recipe_name(fluid_prototype.name)] then
      global.barrelable_fluids[fluid_prototype.name] = {
        fill_recipe_name = fill_barrel_recipe_name(fluid_prototype.name),
        empty_recipe_name = empty_barrel_recipe_name(fluid_prototype.name),
      }
    end
  end
end

script.on_configuration_changed(on_configuration_changed)

script.on_init(function(event)
  global.pipe_connections = {}
  global.playerdata = {}

  on_configuration_changed()
end)

script.on_event(defines.events.on_player_pipette, function(event)
  local player = game.get_player(event.player_index)

  if player.selected == nil then return end -- deconstructed immediately after or triggered by another mod
  if player.selected.name ~= "pipe-connection" then return end

  local unit_number = script.register_on_entity_destroyed(player.selected)
  local pipe_connection = global.pipe_connections[unit_number]
  if pipe_connection == nil then return error('how?') end

  if player.clear_cursor() == false then return end
  local cursor_stack = player.cursor_stack

  -- code borrowed from raiguard's MIT licenced RecipeBook mod
  if cursor_stack and cursor_stack.valid then
    local collision_box = game.entity_prototypes[pipe_connection.item_name].collision_box
    local height = bounding_box.height(collision_box)
    local width = bounding_box.width(collision_box)
    cursor_stack.set_stack({ name = "blueprint", count = 1 })
    cursor_stack.set_blueprint_entities({
      {
        entity_number = 1,
        name = pipe_connection.item_name,
        position = {
          -- Entities with an even number of tiles to a side need to be set at -0.5 instead of 0
          math.ceil(width) % 2 == 0 and -0.5 or 0,
          math.ceil(height) % 2 == 0 and -0.5 or 0,
        },
        direction = pipe_connection.direction, -- should we have the machine face the port?
        recipe = pipe_connection.drain and global.barrelable_fluids[pipe_connection.fluid_name].fill_recipe_name or global.barrelable_fluids[pipe_connection.fluid_name].empty_recipe_name
      },
    })
    player.add_to_clipboard(cursor_stack)
    player.activate_paste()

    -- could crash if you pipette a pipe connection belonging to a different user and haven't used the mod before, lets just wait for the first crash report :3
    for _, entity in pairs(global.playerdata[player.index].to_destroy) do
      entity.destroy()
    end
    global.playerdata[player.index].to_destroy = {}

  else
    error('guard clause goes brrr')
  end
end)
