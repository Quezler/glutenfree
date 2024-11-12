script.on_nth_tick(60, function(event)
  for struct_id, struct in pairs(storage.structs) do
    if is_belt_read_holding_all_belts(struct.belt) == false then
      game.print("nth 60 delete")
      delete_struct(struct)
    end
  end
end)
