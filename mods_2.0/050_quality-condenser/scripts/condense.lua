local Condense = {}

local get_next_quality_name = {} -- next_quality_name["normal"] = "uncommon"
local get_next_probability = {}

for _, quality in pairs(prototypes.quality) do
  if quality.next then
    get_next_quality_name[quality.name] = quality.next.name
  end
  get_next_probability[quality.name] = quality.next_probability
end

-- log(serpent.block(next_quality_name))

local item_can_spoil = {}
for _, item in pairs(prototypes.item) do
  if item.get_spoil_ticks() > 0 then
    item_can_spoil[item.name] = true
  end
end

local function get_spoil_percentage(inventory, item)
  local spoil_percentage = nil

  for slot = 1, #inventory do
    local stack = inventory[slot]
    if stack.valid_for_read and stack.name == item.name and stack.quality.name == item.quality then
      if spoil_percentage == nil then
        spoil_percentage = stack.spoil_percent
      else
        spoil_percentage = (spoil_percentage + stack.spoil_percent) / 2
      end
    end
  end

  return spoil_percentage
end

local function condensed_nothing(struct)
  struct.entity.disabled_by_script = true
  struct.entity.custom_status = {
    diode = defines.entity_status_diode.yellow,
    label = {"entity-status.sleeping"},
  }
  reset_offering_1(struct)
end

helpers.write_file("quality-condenser.log", "", false, nil)

function Condense.trigger(struct)
  local quality_effect = (struct.entity.effects["quality"] or 0) * 1000
  if 0 >= quality_effect then return condensed_nothing(struct) end

  local condensed_anything = false
  local old_item_count = struct.container_inventory.get_item_count()

  for _, item in ipairs(struct.container_inventory.get_contents()) do
    local next_quality_name = get_next_quality_name[item.quality]
    if next_quality_name and struct.entity.force.is_quality_unlocked(next_quality_name) then

      local quality_points = math.floor(math.min(quality_effect * get_next_probability[item.quality], 1000) + 0.5) -- returns percentage * 10
      local number = quality_points * item.count / 1000
      local integer = math.floor(number)
      local decimal = number - integer

      if integer > 0 then
        -- any leftover points? leave that to chance :)
        if decimal > 0 and math.random() < decimal then
          integer = integer + 1
        end

        helpers.write_file("quality-condenser.log", string.format("%d x %s (%s) x %d%% = %d (%d + %f)\n", item.count, item.name, item.quality, quality_points / 10, integer, number, decimal), true, nil)

        local to_insert = {name = item.name, count = integer, quality = next_quality_name}
        if item_can_spoil[item.name] then
          to_insert["spoil_percent"] = assert(get_spoil_percentage(struct.container_inventory, item))
        end

        assert(struct.container_inventory.remove(item) == item.count) -- all items are consumed, this way there is always space.

        local inserted = struct.container_inventory.insert(to_insert)
        if inserted ~= to_insert.count then
          struct.container_inventory.sort_and_merge()
          to_insert.count = to_insert.count - inserted
          inserted = struct.container_inventory.insert(to_insert)
          assert(inserted == to_insert.count, string.format("inserted only %d of %d %s (%s)", inserted, to_insert.count, item.name, item.quality))
        end

        condensed_anything = true
      end

    end
  end

  if not condensed_anything then
    condensed_nothing(struct)
  else
    struct.container_inventory.sort_and_merge()
  end
end

return Condense
