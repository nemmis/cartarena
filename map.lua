mapModule = {}

function TURQUESE()
  return 0, 206, 209
end

function mapModule.drawMap()

  love.graphics.setColor(TURQUESE())

  local width = love.graphics.getWidth()
  local height = love.graphics.getHeight()

  local bigRadius = height / 4
  local smallRadius = height * 3 / 32

  -- circle in the center
  love.graphics.circle("line", width / 2, height / 2, bigRadius)

  -- four other circles
  love.graphics.circle("line", width * 3 / 16, height / 4, smallRadius)
  love.graphics.circle("line", 13 * width / 16, height / 4, smallRadius)

  love.graphics.circle("line", width * 3 / 16, height * 3 / 4, smallRadius)
  love.graphics.circle("line", 13 * width / 16, height * 3 / 4, smallRadius)

end


return mapModule
