require("namespace")

data:extend{{
    type = "string-setting",
    name = mod_prefix .. "stage",
    order = "a",
    setting_type = "startup",
    allowed_values = {"data", "data-updates", "data-final-fixes"},
    default_value = "data-final-fixes",
}}

data:extend{{
    type = "string-setting",
    name = mod_prefix .. "base64",
    order = "b",
    setting_type = "startup",
    default_value = "",
    allow_blank = true,
    auto_trim = true,
}}
