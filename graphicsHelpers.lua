--[[

= Graphical helpers

]]

local utils = require 'utils'
local colors = require 'color'

local graphicsHelpers = {}

function graphicsHelpers.inWhite()
  love.graphics.setColor(colors.WHITE())
end

------------------------------------
-- Printing
------------------------------------

-- default fonts
local defaultFontBig = love.graphics.newFont(32)
local defaultFontSmall = love.graphics.newFont(12)

function graphicsHelpers.smallPrint()
  love.graphics.setFont(defaultFontSmall)
end

function graphicsHelpers.bigPrint()
  love.graphics.setFont(defaultFontBig)
end

local function printCentered(line, y)
  local WIDTH = love.graphics.getWidth()
  love.graphics.printf(line, 0, y, WIDTH, 'center')
end

-- Print a set of centered lines starting at a given vertical offset
-- y is optional, if not specified the text will be vertically centered
-- @return the height of the written text
function graphicsHelpers.printCentered(lines, y)
  local verticalOffset = y

  local fontHeight = love.graphics.getFont():getHeight()
  local windowHeight = love.graphics.getHeight()

  if not verticalOffset then
    -- center the text vertically
    local linesBlockHeight = #lines * fontHeight
    verticalOffset = windowHeight / 2 - linesBlockHeight / 2
  end

  for i, line in ipairs(lines) do
    printCentered(line, verticalOffset + (i-1) * fontHeight)
  end

  return #lines * fontHeight
end

-- @param lines an array of lines
-- @return the total height of the printed lines
function graphicsHelpers.printLines(lines, x, y)
  utils.assertTypeTable(lines)
  utils.assertTypeNumber(x)
  utils.assertTypeNumber(y)

  local fontHeight = love.graphics.getFont():getHeight()
  for i, line in ipairs(lines) do
    love.graphics.print(line, x, y + (i-1) * fontHeight)
  end

  return fontHeight * #lines
end


return graphicsHelpers
