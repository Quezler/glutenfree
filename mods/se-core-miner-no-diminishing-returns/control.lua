function on_core_miners_equalized()
  -- calculate & set the amount as though there is one miner
  -- delete flying texts at all core seams
end

-- the 4 entry points to equalize that we need to handle:
-- CoreMiner.equalise_all() (on_configuration_changed)
-- CoreMiner.equalise() (on_entity_created)
-- CoreMiner.equalise() (on_entity_removed)
-- CoreMiner.equalise() (generate_core_seam_positions)
