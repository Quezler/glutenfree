require("util")

data.og_extend = data.extend

data.extend = function(self, otherdata)
  data.og_extend(self, otherdata)

  for _, prototype in ipairs(otherdata or self) do
    log(string.format('["%s"]["%s"]', prototype.type, prototype.name))
    if prototype.type == "optimized-decorative" then
      for i, picture in ipairs(prototype.pictures) do
        prototype.pictures[i] = util.empty_sprite()
      end
    end
  end
end

require("__space-age__.prototypes.decorative.decoratives-gleba")

data.extend = data.og_extend
data.og_extend = nil
