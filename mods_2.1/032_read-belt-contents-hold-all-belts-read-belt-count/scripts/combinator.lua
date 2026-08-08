local Combinator = {}

-- comment block left as a relic from the pre 2.0.46 medieval era:

-- this code looks horrid, is probably a bit slow, but hey it works.
-- here are the requirements in case you want to give improving it a go:
-- 1) it must match the ingame visualization
-- 2) there should be a "belt tile count", this includes the underground gap
-- 3) linked belts just count as 2 (just like 2 belts or 2 back-to-back undergrounds)
-- 4) we do not care about partial tiles, like the line starting or stopping on a splitter
-- 5) we only care about transport belts, underground belts, and linked belts
-- 6) linked belts are low priority, and the 1x1 and 1x2 splitters even less

function Combinator.tick_struct(struct)
  if struct.belt.valid == false then return end

  if is_belt_read_holding_all_belts(struct.belt) == false then
    -- game.print("nth 60 delete")
    delete_struct(struct)
  else
    local total_belt_reader_length = struct.belt.type == "entity-ghost" and 0 or (struct.belt.get_transport_line(1).total_segment_length + struct.belt.get_transport_line(2).total_segment_length) / 2
    local section = struct.combinator_cb.get_section(1)
    local filter = section.get_slot(1)
    filter.min = total_belt_reader_length
    section.set_slot(1, filter)
  end
end

script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    Combinator.tick_struct(struct)
  end
end)

return Combinator
