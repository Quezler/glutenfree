for _, suffix in ipairs({"red", "yellow", "green"}) do
  data:extend{{
    type = "sprite",
    name = "notice-me-senpai-" .. suffix,

    filename = "__notice-me-senpai__/graphics/icons/notice-me-senpai-" .. suffix .. ".png",
    size = 64,
    flags = {"icon"},
    scale = 0.45,
  }}
end

