require("namespace")

data:extend{{
    type = "string-setting",
    name = mod_prefix .. "base64",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    auto_trim = true,
}}
