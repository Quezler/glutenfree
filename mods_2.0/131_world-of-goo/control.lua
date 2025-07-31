require("util")
require("namespace")

local function get_random_eye_name()
  -- return "generic-eye-glass-2"
  return "generic-eye-glass-" .. tostring(math.random(1, 3))
end

local is_water = util.list_to_map({"water", "deepwater"})

local function render_goo_ball(fish)
  local body = "common-body"

  -- log(fish.surface.get_tile(fish.position).name)
  if is_water[fish.surface.get_tile(fish.position).name] then
    body = "drool-body"
  end

  local scale = math.random(8, 12) / 10
  rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = body,
    x_scale = scale,
    y_scale = scale,
  }

  if body == "drool-body" then return end -- those have no eyes

  local use_target_orientation = false
  local orientation_target = fish.position

  if math.random() < 0.5 then
    use_target_orientation = true
    orientation_target = fish
  end

  local left_eye = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = get_random_eye_name(),
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = {-0.15, -0.05},
  }

  local right_eye = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = get_random_eye_name(),
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = { 0.15, -0.05},
  }

  local left_pupil = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = "generic-pupil",
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = {-0.15, -0.07},
  }

  local right_pupil = rendering.draw_sprite{
    render_layer = "resource",
    surface = fish.surface,
    target = {entity = fish},
    sprite = "generic-pupil",
    use_target_orientation = use_target_orientation,
    orientation_target = orientation_target,
    oriented_offset = { 0.15, -0.07},
  }

  -- local unit_number = script.register_on_object_destroyed(fish)
  -- storage.goo_balls[unit_number] = {
  --   entity = fish,

  --   left_eye = left_eye,
  --   right_eye = right_eye,
  --   left_pupil = left_pupil,
  --   right_pupil = right_pupil,
  -- }
end

-- commands.add_command("goo-balls", nil, function(command)
--   local player = game.get_player(command.player_index) --[[@as LuaPlayer]]
--   local fishes = player.surface.find_entities_filtered{type = "fish"}
--   game.print(#fishes)

--   for _, fish in ipairs(fishes) do
--     render_goo_ball(fish)
--   end
-- end)

local function generate_pool_around_pipe(pipe)
  local tiles = pipe.surface.get_connected_tiles(
    --[[position = --]] pipe.position,
    --[[tiles = --]] {
      mod_prefix .. "goo-filled-rock" ,
      mod_prefix .. "goo-filled-dust" ,
      mod_prefix .. "goo-filled-sand" ,
      mod_prefix .. "goo-filled-dunes",
    },
    --[[include_diagonal = --]] true,
    --[[area = --]] {{pipe.position.x - 10, pipe.position.y - 10}, {pipe.position.x + 10, pipe.position.y + 10}}
  )

  if #tiles == 0 then return end -- pipe not placed on the green tiles over at the world of goo

  local to_set = {}
  local pipe_position = {x = pipe.position.x - 0.5, y = pipe.position.y - 0.5}

  for _, tile_position in ipairs(tiles) do
    local distance = util.distance(pipe_position, tile_position)
    if math.random() > 0.8 then
      distance = math.random(distance, distance + 1)
    end
    if 6 > distance then
      table.insert(to_set, {position = tile_position, name = "deepwater"})
    elseif 8 > distance then
      table.insert(to_set, {position = tile_position, name = "water"})
    elseif 9 > distance then
      table.insert(to_set, {position = tile_position, name = mod_prefix .. "goo-filled-dunes"})
    end
  end

  table.insert(to_set, {position = pipe_position, name = mod_prefix .. "pipe-cap-tile"})
  pipe.surface.set_tiles(to_set)
  -- game.players[1].teleport(pipe.position)

  for i = 1, math.random(10, 30) do
    pipe.surface.create_entity{
      name = "goo-ball",
      force = "neutral",
      position = {pipe.position.x, pipe.position.y - 1.75}
    }
  end
end

-- does not trigger for the spawning pool, caught by on_init instead, weird right?
script.on_event(defines.events.on_script_trigger_effect, function(event)
  if event.effect_id == "goo-ball-created" then
    render_goo_ball(event.source_entity)
  elseif event.effect_id == mod_prefix .. "pipe-cap-created" then
    generate_pool_around_pipe(event.source_entity)
  end
end)

script.on_init(function()
  storage.goo_balls = {}
  storage.goo_balls_next = nil

  for _, surface in pairs(game.surfaces) do
    for _, entity in ipairs(surface.find_entities_filtered{name = "goo-ball"}) do
      render_goo_ball(entity) -- probably only nauvis
    end
  end
end)

-- script.on_event(defines.events.on_tick, function()
--   local unit_number, struct = next(storage.goo_balls, storage.goo_balls_next)
--   storage.goo_balls_next = unit_number

--   if struct then
--     if not struct.entity.valid then
--       storage.goo_balls[unit_number] = nil
--     else
--       local entities = struct.entity.surface.find_entities_filtered{
--         position = struct.entity.position,
--         range = 5,
--       }
--       local entity = entities[math.random(1, #entities)] -- should always contain at least one: itself
--       struct.left_eye.orientation_target = entity
--       struct.right_eye.orientation_target = entity
--       struct.left_pupil.orientation_target = entity
--       struct.right_pupil.orientation_target = entity
--     end
--   end
-- end)

script.on_event(defines.events.on_player_created, function(event)
  local player = game.get_player(event.player_index) --[[@as LuaPlayer]]

  if player.controller_type == defines.controllers.cutscene then
    player.exit_cutscene()
  end

  game.planets["world-of-goo"].create_surface()
  player.teleport({0, 0}, "world-of-goo")
end)
