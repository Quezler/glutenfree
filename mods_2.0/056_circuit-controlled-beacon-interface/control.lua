local mod_prefix = "circuit-controlled-beacon-interface--"

require("util")

if script.active_mods["EditorExtensions"] then
  -- due to lack of a "starting items interface" for `items_to_add` like freeplay has, we'll just have to bodge it
  script.on_event(defines.events.on_player_created, function(event)
    local player = game.get_player(event.player_index) --[[@as LuaPlayer]]
    local inventory = player.get_inventory(defines.inventory.character_main) --[[@as LuaInventory]]
    if inventory.get_item_count("ee-super-substation") > 0 then -- detect whether "ee.set_loadout()" ran
      inventory.insert({name = mod_prefix .. "beacon", count = 20})
    end
  end)
end

-- the first 4 lines inside this function are paraphrased from the MIT licenced "Editor Extentions" mod by raiguard
script.on_event(defines.events.on_console_command, function (event)
  if event.command ~= "cheat" or not game.console_command_used then return end
  local player = game.get_player(event.player_index)
  if not player then return end
  if event.parameters ~= "all" then return end

  local inventory = player.get_inventory(defines.inventory.character_main) --[[@as LuaInventory]]
  inventory.insert({name = mod_prefix .. "beacon", count = 20})
end)

script.on_init(function()
  storage.structs = {}
  storage.deathrattles = {}
end)

local function new_struct(table, struct)
  assert(struct.id, serpent.block(struct))
  assert(table[struct.id] == nil)
  table[struct.id] = struct
  return struct
end

local Handler = {}

function Handler.on_created_entity(event)
  local entity = event.entity or event.destination

  local struct = new_struct(storage.structs, {
    id = entity.unit_number,
    entity = entity,
    power_switch = nil,
    effects = {
      speed = 0,
      productivity = 0,
      consumption = 0,
      pollution = 0,
      quality = 0,
    },
  })

  storage.deathrattles[script.register_on_object_destroyed(entity)] = {"struct", struct.id}

  struct.power_switch = entity.surface.create_entity{
    name = mod_prefix .. "beacon-control-behavior",
    force = entity.force,
    position = {entity.position.x + 1, entity.position.y},
  }
  struct.power_switch.destructible = false
  struct.power_switch.operable = false
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
    {filter = "name", name = mod_prefix .. "beacon"},
  })
end

local signal_to_effect_map = {
  ["signal-S"] = "speed",
  ["signal-P"] = "productivity",
  ["signal-C"] = "consumption",
  ["signal-E"] = "pollution",
  ["signal-Q"] = "quality",
}

local function tick_struct(struct)
  local new_effects = {
    speed = 0,
    productivity = 0,
    consumption = 0,
    pollution = 0,
    quality = 0
  }

  local signals = struct.power_switch.get_signals(defines.wire_connector_id.circuit_red, defines.wire_connector_id.circuit_green)
  for _, signal in ipairs(signals or {}) do
    local effect = signal_to_effect_map[signal.signal.name]
    if effect then
      new_effects[effect] = math.max(-32768, math.min(32767, signal.count)) -- if we do not clamp it the beacon interface will error
    end
  end

  -- the beacon interface mod refreshes the beacon whenever we write,
  -- so lets make sure we only call the remote if we detect any changes.
  if table.compare(struct.effects, new_effects) then return end

  struct.effects = new_effects
  -- game.print(serpent.line(new_effects))
  remote.call("beacon-interface", "set_effects", struct.id, new_effects)
end

script.on_nth_tick(60, function(event)
  for _, struct in pairs(storage.structs) do
    tick_struct(struct)
  end
end)

script.on_event(defines.events.on_object_destroyed, function(event)
  local deathrattle = storage.deathrattles[event.registration_number]
  if deathrattle then storage.deathrattles[event.registration_number] = nil

    if deathrattle[1] == "struct" then
      storage.structs[deathrattle[2]].power_switch.destroy()
      storage.structs[deathrattle[2]] = nil
    else
      error(serpent.block(deathrattle))
    end
  end
end)
