local util = require ('util')
local flib_bounding_box = require("__flib__/bounding-box")
local Handler = {}

--

function Handler.on_init(event)
  global.surfaces = {}

  for _, surface in pairs(game.surfaces) do
    Handler.on_surface_created({surface_index = surface.index})
  end
end

function Handler.on_surface_created(event)
  global.surfaces[event.surface_index] = {
    botmalls = {},
  }
end

function Handler.on_surface_deleted(event)
  global.surfaces[event.surface_index] = nil
end

function Handler.on_player_selected_area(event)
  if event.item ~= "daan-we-have-botmall-at-home" then return end

  -- game.print(serpent.block(event.area))

  -- event.area.left_top.x = math.floor(event.area.left_top.x)
  -- event.area.left_top.y = math.floor(event.area.left_top.y)
  -- event.area.right_bottom.x = math.ceil(event.area.right_bottom.x)
  -- event.area.right_bottom.y = math.ceil(event.area.right_bottom.y)

  local area = flib_bounding_box.ceil(event.area)
  
  ::remerge::
  local merged = false

  for registration_number, botmall in pairs(global.surfaces[event.surface.index].botmalls) do
    if flib_bounding_box.intersects_box(area, botmall.area) then
      area = flib_bounding_box.expand_to_contain_box(area, botmall.area)
      global.surfaces[event.surface.index].botmalls[registration_number] = nil
      botmall.highlightbox.destroy()
      for _, line in ipairs(botmall.lines) do
        rendering.destroy(line)
      end
      merged = true
    end
  end

  -- if 2 rectangles merge it could overlap with a prevously non-overlapping area
  if merged then goto remerge end

  local highlightbox = event.surface.create_entity{
    name = 'highlight-box',
    position = {0, 0},
    bounding_box = area,
    box_type = 'train-visualization',
    -- time_to_live = 60,
  }

  global.surfaces[event.surface.index].botmalls[script.register_on_entity_destroyed(highlightbox)] = {
    area = area,
    highlightbox = highlightbox,
    lines = {},
  }

  Handler.refresh_lines(event.surface, area)
end

function Handler.on_player_reverse_selected_area(event)
  if event.item ~= "daan-we-have-botmall-at-home" then return end

  for registration_number, botmall in pairs(global.surfaces[event.surface.index].botmalls) do
    if flib_bounding_box.intersects_box(event.area, botmall.area) then
      global.surfaces[event.surface.index].botmalls[registration_number] = nil
      botmall.highlightbox.destroy()
      for _, line in ipairs(botmall.lines) do
        rendering.destroy(line)
      end
    end
  end
end

function Handler.refresh_lines(surface, bounding_box)
  for registration_number, botmall in pairs(global.surfaces[surface.index].botmalls) do
    if flib_bounding_box.intersects_box(bounding_box, botmall.area) then

      for _, line in ipairs(botmall.lines) do
        rendering.destroy(line)
      end
      botmall.lines = {}

      local crafters = surface.find_entities_filtered{
        area = botmall.area,
        type = {'assembling-machine', 'rocket-silo', 'furnace'}, -- CraftingMachinePrototype
      }
    
      local spiderweb = {}
    
      for _, crafter in ipairs(crafters) do
        local recipe = crafter.get_recipe()
        if recipe then
          if not spiderweb[recipe.name] then
            spiderweb[recipe.name] = {}
          end
    
          for _, other in ipairs(spiderweb[recipe.name]) do
            local line = rendering.draw_line{
              color = {r = 0.9, g = 0.9, b = 0.9},
              width = 32 / 8,
              from = crafter,
              to = other,
              surface = surface,
            }
            table.insert(botmall.lines, line)
          end
    
          table.insert(spiderweb[recipe.name], crafter)
        end
      end

      return
    end
  end
end

local type_triggers_refresh = util.list_to_map({'assembling-machine', 'rocket-silo', 'furnace'})

function Handler.on_recipe_changed(event)
  local entity = event.entity or event.destination
  if not entity then return end

  if not type_triggers_refresh[entity.type] then return end
  Handler.refresh_lines(entity.surface, entity.selection_box)
end

return Handler
