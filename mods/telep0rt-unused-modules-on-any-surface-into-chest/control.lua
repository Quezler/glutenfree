local cache = {}

function cache.get_stack_size(item_name)
  if cache.stack_size == nil then
    cache.stack_size = {}
  end

  if cache.stack_size[item_name] == nil then
    cache.stack_size[item_name] = game.item_prototypes[item_name].stack_size
  end

  return cache.stack_size[item_name]
end

local function tick_force(force)
  if global.chest_for_force[force.index] == nil then return end
  if global.chest_for_force[force.index].valid == false then return end

  local module_inventory = global.chest_for_force[force.index].get_inventory(defines.inventory.chest)

  for surface_name, networks in pairs(force.logistic_networks) do
    for _, network in ipairs(networks) do

      if #network.cells == 1 and network.cells[1].owner.type == 'character' then
        goto continue
      end

      for _, module_name in ipairs(global.module_names) do

        local missing_count = cache.get_stack_size(module_name) - module_inventory.get_item_count(module_name)
        if missing_count > 0 then

          local in_storage = network.get_supply_counts(module_name).storage
          if in_storage > 0 then

            local inserted = module_inventory.insert({name = module_name, count = math.min(in_storage, missing_count)})
            if inserted > 0 then

              local removed = network.remove_item({name = module_name, count = inserted}, 'storage')
              assert(inserted == removed)

              log(string.format('[%s] teleported %d x %s from %s to %s.', force.name, removed, module_name, surface_name, global.chest_for_force[force.index].surface.name))
            end
          end
        end
      end

      ::continue::

    end
  end
end

local function on_configuration_changed(event)
  global.module_names = {}
  
  local module_prototypes = game.get_filtered_item_prototypes({{filter = 'type', type = 'module'}})
  for module_name, module_prototype in pairs(module_prototypes) do
    table.insert(global.module_names, module_name)
  end
end

script.on_init(function(event)
  global.chest_for_force = {} -- why is there no on_force_deleted event so the to-be-reused id's can be cleared?

  on_configuration_changed(event)
end)

script.on_configuration_changed(on_configuration_changed)

local function trigger()
  for _, force in pairs(game.forces) do
    tick_force(force)
  end
end

script.on_nth_tick(60 * 60, trigger) -- every minute

commands.add_command('teleport-unused-modules-on-any-surface-into-this-chest', nil, function(command)
  local player = game.get_player(command.player_index)
  if player.selected == nil then return end
  if player.selected.unit_number == nil then return end

  local inventory = player.selected.get_inventory(defines.inventory.chest)
  if inventory == nil then return end

  global.chest_for_force[player.force.index] = player.selected

  trigger()
end)
