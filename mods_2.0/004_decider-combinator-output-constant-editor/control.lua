local function find_output(selected_prototype, outputs)
  for i, output in ipairs(outputs) do
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

  local textfield = player.gui.relative['dcov-textfield'] or player.gui.relative.add{
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
  assert(opened and opened.type == 'decider-combinator')

  local playerdata = storage.playerdata[player.index]

  local outputs = opened.get_control_behavior().parameters.outputs
  local index, output = find_output(playerdata.selected_prototype, outputs)

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
