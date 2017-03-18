local colors = require 'color'

local mapModule = {}

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

-- TODO change this, make map a class
function mapModule.getStartingPositions()
  return {{x = 50, y = 50, theta = 0}, {x = 100, y = 100, theta = 0}}
end

-- the map is a singleton
function mapModule.init(collisionEngine)
  mapModule.collisionEngine = collisionEngine

  -- enforce map boundaries
  local boundaryWidth = 500
  local visibleWidth = HEIGHT / 100
  mapModule.up = mapModule.collisionEngine.rectangle(0, -boundaryWidth + visibleWidth, WIDTH, boundaryWidth)
  mapModule.down = mapModule.collisionEngine.rectangle(0, HEIGHT - visibleWidth, WIDTH, boundaryWidth)
  mapModule.left = mapModule.collisionEngine.rectangle(-boundaryWidth + visibleWidth, 0, boundaryWidth, HEIGHT)
  mapModule.right = mapModule.collisionEngine.rectangle(WIDTH - visibleWidth, 0, boundaryWidth, HEIGHT)

  -- shapes are stored directly as a HC shape, TODO change this later
  mapModule.rectangle = {
    ax = 4* WIDTH/12,
    ay = 3 * HEIGHT/8,
    width = 3 * WIDTH / 10,
    height = 3 * HEIGHT / 10}
  mapModule.rectangle.bbColl = mapModule.collisionEngine.rectangle(mapModule.rectangle.ax, mapModule.rectangle.ay, mapModule.rectangle.width, mapModule.rectangle.height)
  mapModule.rectangle.bbColl:rotate(1)

  mapModule.rectangle2 = {
    ax = WIDTH/4 - 3 * WIDTH / 20,
    ay = HEIGHT/2,
    width = WIDTH / 12,
    height = 3 * HEIGHT / 12}
  mapModule.rectangle2.bbColl = mapModule.collisionEngine.rectangle(mapModule.rectangle2.ax, mapModule.rectangle2.ay, mapModule.rectangle2.width, mapModule.rectangle2.height)

  mapModule.circle = {
    cx = 3* WIDTH / 4,
    cy = 2* HEIGHT / 7,
    radius = HEIGHT / 7
  }
  mapModule.circle.bbColl = mapModule.collisionEngine.circle(mapModule.circle.cx, mapModule.circle.cy, mapModule.circle.radius)

  local bigRadius = HEIGHT / 4
  local smallRadius = WIDTH * 3 / 32

  -- circle in the center
  love.graphics.circle("line", WIDTH / 2, HEIGHT / 2, bigRadius)
end

function mapModule.draw()

  love.graphics.setColor(colors.TURQUESE())

  -- boundaries
  mapModule.up:draw()
  mapModule.down:draw()
  mapModule.right:draw()
  mapModule.left:draw()
  mapModule.rectangle.bbColl:draw()
  mapModule.rectangle2.bbColl:draw()
  mapModule.circle.bbColl:draw()

end


return mapModule
