local function any_feature_flag_enabled()
  for feature_flag, boolean in pairs(feature_flags) do
    if boolean then return true end
  end
end

if not any_feature_flag_enabled() then
  error("at least one feature flag must be enabled.")
end
