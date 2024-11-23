require("util")

local UndergroundHeatPipe = {}

local heat_pipe_item = data.raw["item"]["heat-pipe"]
local heat_pipe_entity = data.raw["heat-pipe"]["heat-pipe"]

local subgroup = {
  type = "item-subgroup",
  name = "underground-heat-pipe",
  group = "production",
  order = "b-2",
}

data:extend{subgroup}

function UndergroundHeatPipe.make(config)
  local underground_belt = table.deepcopy(data.raw["underground-belt"][config.prefix .. "underground-belt"])

  local uhp = {
    type = "pipe-to-ground",
    name = config.prefix .. "underground-heat-pipe",
    icons = {
      {draw_background = false, icon = "__core__/graphics/empty.png"},
      {draw_background = false, icon = heat_pipe_item.icon, scale = 0.3, shift = {-4, 0}},
      {draw_background = true,  icon = underground_belt.icon, scale = 0.4}
    },
    fluid_box = {
      volume = 1,
      pipe_connections =
      {
        {
          connection_type = "underground",
          direction = defines.direction.south,
          position = {0, 0},
          max_underground_distance = underground_belt.max_distance,
          connection_category = config.prefix .. "underground-heat-pipe",
        }
      },
      hide_connection_info = true,
      max_pipeline_extent = underground_belt.max_distance + 1,
    },
    collision_box = {{-0.3, -0.3}, {0.3, 0.3}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},

    max_health = underground_belt.max_health,
    resistances = underground_belt.resistances,
    flags = {"player-creation"},
  }

  local uhp_item = {
    type = "item",
    name = config.prefix .. "underground-heat-pipe",
    icons = uhp.icons,
    subgroup = subgroup.name,
    color_hint = data.raw["item"][config.prefix .. "underground-belt"].color_hint,
    order = string.format("a[underground-heat-pipe]-%s[%s]", config.order, config.prefix .. "underground-heat-pipe"),
    inventory_move_sound = underground_belt.inventory_move_sound,
    pick_sound = underground_belt.pick_sound,
    drop_sound = underground_belt.drop_sound,
    place_result = uhp.name,
    stack_size = 10,
  }

  uhp.minable = table.deepcopy(underground_belt.minable)
  uhp.minable.result = uhp_item.name

  local uhp_recipe = {
    type = "recipe",
    name = uhp_item.name,
    enabled = false,
    energy_required = 1,
    ingredients =
    {
      {type = "item", name = "heat-pipe", amount = underground_belt.max_distance + 1},
      {type = "item", name = config.prefix .. "underground-belt", amount = 2}
    },
    results = {{type="item", name=uhp_item.name, amount=2}}
  }

  local direction_out = table.deepcopy(underground_belt.structure.direction_out.sheet)
  direction_out.scale = 0.25
  uhp.pictures = {
    north = table.deepcopy(direction_out),
    south = table.deepcopy(direction_out),
    west  = table.deepcopy(direction_out),
    east  = table.deepcopy(direction_out),
  }

  uhp.pictures.south.x = 192 * 0
  uhp.pictures.west.x  = 192 * 1
  uhp.pictures.north.x = 192 * 2
  uhp.pictures.east.x  = 192 * 3

  data:extend{uhp, uhp_item, uhp_recipe}

  for length = 3, underground_belt.max_distance + 1 do
    local range = (length - 3) / 2 -- as in, half of the diameter, minus the center or something.
    -- right = vertical, left = horizontal
    for axis, offset in pairs({horizontal = {x = range, y = 0}, vertical = {x = 0, y = range}}) do
      local icons = table.deepcopy(uhp.icons)
      table.insert(icons, {
        icon = "__base__/graphics/icons/signal/signal_" .. axis:sub(1, 1) .. ".png",
        icon_size = 64,
        scale = 0.25,
        shift = {-8, -8}
      })
      local zero_padded_length_string = string.format("%02d", length - 2)
      assert(string.len(zero_padded_length_string) == 2) -- why would a transport belt even span 100+ tiles?
      table.insert(icons, {
        icon = "__base__/graphics/icons/signal/signal_" .. zero_padded_length_string:sub(-1) .. ".png",
        icon_size = 64,
        scale = 0.25,
        shift = {8, -8}
      })
      local heat_pipe_long = {
        type = "heat-pipe",
        name = string.format("underground-heat-pipe-long-%s-%s", axis, zero_padded_length_string), -- no prefix, shared.
        localised_name = {"entity-name.underground-heat-pipe-long-axis-length", axis, zero_padded_length_string},
        icons = icons,
        heat_buffer = table.deepcopy(heat_pipe_entity.heat_buffer),
        collision_box = {{-0.1 - offset.x, -0.1 - offset.y}, {0.1 + offset.x, 0.1 + offset.y}},
        selection_box = {{-0.4 - offset.x, -0.4 - offset.y}, {0.4 + offset.x, 0.4 + offset.y}},
        collision_mask = {layers = {}},
        selectable_in_game = false,
        selection_priority = 49,
        hidden = true,
        flags = {"not-on-map"},
      }

      -- heat_pipe_long.connection_sprites = table.deepcopy(heat_pipe_entity.connection_sprites)

      if axis == "horizontal" then
        heat_pipe_long.heat_buffer.connections = {
          {position = {- offset.x, 0}, direction = defines.direction.west},
          {position = {  offset.x, 0}, direction = defines.direction.east},
        }
      else
        heat_pipe_long.heat_buffer.connections = {
          {position = {0, - offset.y}, direction = defines.direction.north},
          {position = {0,   offset.y}, direction = defines.direction.south},
        }
      end

      -- the first prototype that requests an underpass of this name will have dibs on the sprite
      if data.raw["heat-pipe"][heat_pipe_long.name] == nil then data:extend{heat_pipe_long} end
    end
  end

  for _, direction_name in ipairs({"north", "east", "south", "west"}) do
    for _, mode in ipairs({"single", "duo"}) do
      for _, even_or_odd in ipairs({"even", "odd"}) do -- adjacent heat pipes with the same name still try to visually form connections.
        local icons = table.deepcopy(uhp.icons)
        table.insert(icons, {
          icon = "__base__/graphics/icons/signal/signal_" .. direction_name:sub(1, 1) .. ".png",
          icon_size = 64,
          scale = 0.25,
          shift = {-8, -8}
        })
        table.insert(icons, {
          icon = "__base__/graphics/icons/signal/signal_" .. (even_or_odd == "even" and "green" or "red") .. ".png",
          icon_size = 64,
          scale = 0.25,
          shift = { 8, -8}
        })

        local heat_pipe_direction = {
          type = "heat-pipe",
          name = string.format(config.prefix .. "underground-heat-pipe-%s-%s-%s", direction_name, mode, even_or_odd),
          localised_name = {"entity-name.underground-heat-pipe-direction-mode", direction_name, mode},
          icons = icons,
          heat_buffer = table.deepcopy(heat_pipe_entity.heat_buffer),
          collision_box = {{-0.2, -0.2}, {0.2, 0.2}},
          selection_box = {{-0.1, -0.1}, {0.1, 0.1}},
          collision_mask = {layers = {}},
          selection_priority = 51,
          selectable_in_game = false,
          hidden = true,
        }

        for _, spriteconfig in ipairs({{key = "connection_sprites", prefix = ""}, {key = "heat_glow_sprites", prefix = "heated-"}}) do
          local template_off = {
            filename = "__base__/graphics/entity/heat-pipe/heat-pipe-straight-vertical-single.png",
            height = 64,
            priority = "extra-high",
            scale = 0.5,
            width = 64
          }
          template_off.filename = string.format("__underground-heat-pipe__/graphics/entity/underground-heat-pipe/%sunderground-heat-pipe-%s-disconnected.png", spriteconfig.prefix, direction_name)

          local template_on = table.deepcopy(template_off)
          template_on.filename = string.format("__underground-heat-pipe__/graphics/entity/underground-heat-pipe/%sunderground-heat-pipe-%s-connected.png", spriteconfig.prefix, direction_name)

          heat_pipe_direction[spriteconfig.key] = table.deepcopy(heat_pipe_entity[spriteconfig.key])
          heat_pipe_direction[spriteconfig.key].single = template_off
          heat_pipe_direction[spriteconfig.key].ending_left  = template_off
          heat_pipe_direction[spriteconfig.key].ending_right = template_off
          heat_pipe_direction[spriteconfig.key].ending_up    = template_off
          heat_pipe_direction[spriteconfig.key].ending_down  = template_off
          if direction_name == "west"  then heat_pipe_direction[spriteconfig.key].ending_left  = template_on end
          if direction_name == "east"  then heat_pipe_direction[spriteconfig.key].ending_right = template_on end
          if direction_name == "north" then heat_pipe_direction[spriteconfig.key].ending_up    = template_on end
          if direction_name == "south" then heat_pipe_direction[spriteconfig.key].ending_down  = template_on end

          heat_pipe_direction[spriteconfig.key].straight_horizontal = template_on
          heat_pipe_direction[spriteconfig.key].straight_vertical   = template_on
        end

        if mode == "single" then
          heat_pipe_direction.heat_buffer.connections = {
            {position = {0, 0}, direction = defines.direction[direction_name]},
          }
        elseif mode == "duo" then
          heat_pipe_direction.heat_buffer.connections = {
            {position = {0, 0}, direction = defines.direction[direction_name]},
            {position = {0, 0}, direction = util.oppositedirection(defines.direction[direction_name])},
          }
        else
          error(mode)
        end


        data:extend{heat_pipe_direction}
      end
    end
  end
end

return UndergroundHeatPipe
