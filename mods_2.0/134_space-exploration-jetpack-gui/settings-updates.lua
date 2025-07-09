-- my testing world has lifesupport set to hidden, can't be bothered to re-save it with it set to always, so this is a development debug toggle
if false then
  data.raw['string-setting']['se-lifesupport-hud-visibility'].allowed_values = {"option-1"}
  data.raw['string-setting']['se-lifesupport-hud-visibility'].default_value = "option-1"
end
