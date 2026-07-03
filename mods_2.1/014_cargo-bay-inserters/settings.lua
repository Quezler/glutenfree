require("shared")

local function create_startup_setting(entity_name, default_value, order)
  data:extend{
    {
      type = "string-setting",
      name = entity_name .. "-mode",
      setting_type = "startup",
      allowed_values = {"input/output", "input", "output", "none"},
      default_value = default_value,
      order = order,
    }
  }
end

create_startup_setting(mod_prefix .. "platform-cargo-bay-proxy", "input/output", "a")
create_startup_setting(mod_prefix .. "planet-cargo-bay-proxy", "output", "b")
