local function find_output(selected_prototype, outputs)
  for i, output in ipairs(outputs or {}) do
    if output.signal and output.signal.name == selected_prototype.name then
      return i, output
    end
  end
end

script.on_event('dcoce-i', function(event)
  local player = assert(game.get_player(event.player_index))
  local opened = player.opened

  if opened == nil then return end
  if opened.type ~= "decider-combinator" then return end

  if event.selected_prototype == nil then
    return player.create_local_flying_text{
      text = 'press i over one of the output icons.',
      create_at_cursor = true,
    }
  end

  local outputs = opened.get_control_behavior().parameters.outputs

  -- game.print('blep')
  -- game.print(serpent.block(opened.get_control_behavior().parameters.outputs))

  -- game.print(event.tick)
  -- game.print(serpent.block(event.selected_prototype))

  local index, output = find_output(event.selected_prototype, outputs)
  if index == nil then
    return player.create_local_flying_text{
      text = 'press i over one of the OUTPUT icons.',
      create_at_cursor = true,
    }
  end

  -- player.gui.screen.add{
    -- type = 'textfield',
    -- numeric = true,
  -- }

  -- game.print(serpent.block(output))

  local textfield = player.gui.relative['dcoce-textfield'] or player.gui.relative.add{
    type = 'textfield',
    name = 'dcoce-textfield',
    numeric = true,
    allow_negative = true,
    anchor = {
      gui = defines.relative_gui_type.decider_combinator_gui,
      position = defines.relative_gui_position.bottom,
    },
  }

  -- output.constant = 10
  -- opened.get_control_behavior().set_output(index, output)

  textfield.style.width = 884
  textfield.style.top_margin = 10
  -- textfield.style.horizontally_squashable = true

  textfield.text = '' .. (output.constant or 1)
  textfield.focus()

  storage.playerdata[player.index] = {
    -- entity = opened,
    selected_prototype = event.selected_prototype,
  }

  -- game.print(index)
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
  if event.element.name ~= 'dcoce-textfield' then return end

  local player = assert(game.get_player(event.player_index))
  local opened = player.opened
  if not (opened and opened.type == 'decider-combinator') then
    game.print("latency issue, decider combinator already removed.")
    return
  end

  local playerdata = storage.playerdata[player.index]

  local outputs = opened.get_control_behavior().parameters.outputs
  local index, output = find_output(playerdata.selected_prototype, outputs)
  if index == nil then
    player.gui.relative['dcoce-textfield'].destroy()
    storage.playerdata[player.index] = nil
    return player.create_local_flying_text{
      text = 'some dingus removed the output you are editing.',
      create_at_cursor = true,
    }
  end

  local number = tonumber(event.element.text) or 0

  if number > 2147483647 then
    number = 2147483647
    event.element.text = tostring(number)
  end

  if number < -2147483648 then
    number = -2147483648
    event.element.text = tostring(number)
  end

  output.constant = number
  opened.get_control_behavior().set_output(index, output)
end)

-- script.on_event(defines.events.on_gui_confirmed, function(event)
--   if event.element.name ~= 'dcoce-textfield' then return end

--   event.element.destroy()
-- end)

script.on_event(defines.events.on_gui_closed, function(event)
  if event.entity and event.entity.type == 'decider-combinator' then
    local player = assert(game.get_player(event.player_index))

    local textfield = player.gui.relative['dcoce-textfield']
    if textfield then
      textfield.destroy()
      storage.playerdata[player.index] = nil
    end
  end
end)

script.on_init(function()
  storage.playerdata = {}
end)

commands.add_command("decider-combinator-output-constant-detector", "Receive a selection tool that detects deciders with constants.", function(command)
  local player = game.get_player(command.player_index)
  assert(player)

  player.clear_cursor()
  if player.cursor_stack.valid_for_read == true then return end -- cursor not cleared?

  player.cursor_stack.set_stack({name = "decider-combinator-output-constant-detector"})
end)

local function decider_combinator_has_custom_constants(decider_combinator)
  local parameters = decider_combinator.get_control_behavior().parameters

  for _, output in ipairs(parameters.outputs) do
    if output.constant ~= nil then
      assert(output.constant ~= 1) -- if its the default it should be nil
      return true
    end
  end

  return false
end

local function on_player_selected_area(event)
  local player = assert(game.get_player(event.player_index))
  local surface = event.surface

  local total = 0

  for _, decider_combinator in ipairs(event.entities) do
    if decider_combinator_has_custom_constants(decider_combinator) then
      surface.create_entity{
        name = "highlight-box",
        position = decider_combinator.position,
        bounding_box = decider_combinator.selection_box,
        box_type = "train-visualization", -- white
        render_player_index = player.index,
        -- blink_interval = 30,
        time_to_live = 60 * 5, -- 5 seconds
      }
      total = total + 1
    end
  end

  player.create_local_flying_text{
    text = total .. " have custom constants.",
    create_at_cursor = true,
  }
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)
