local utils = require 'utils'

local colors = {}

function colors.TURQUESE()
  return 0, 206, 209
end

function colors.ORANGE()
  return 223, 116, 12
end

function colors.BLACK()
  return 0, 0, 0
end

function colors.WHITE()
  return 255, 255, 255
end

function colors.GREEN()
  return 0, 255, 0
end

function colors.PURPLE()
  return 255, 0, 255
end

function colors.GREY(g)
  local gg = g or 125
  return gg, gg, gg
end

function colors.getColor(r, g, b)
  utils.assertTypeNumber(r)
  utils.assertTypeNumber(g)
  utils.assertTypeNumber(b)
  return {r = r, g = g, b = b}
end

function colors.getRGB(color)
  utils.assertTypeTable(color)
  return color.r, color.g, color.b
end

return colors
