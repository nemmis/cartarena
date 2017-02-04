local colors = require 'color'

local mapModule = {}

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

-- the map is a singleton
function mapModule.init(collisionEngine)
  mapModule.collisionEngine = collisionEngine

  -- enforce map boundaries
  mapModule.up = mapModule.collisionEngine.rectangle(0, 0, WIDTH, HEIGHT / 100)
  mapModule.down = mapModule.collisionEngine.rectangle(0, HEIGHT * 99 / 100, WIDTH, HEIGHT / 100)
  mapModule.left = mapModule.collisionEngine.rectangle(0, 0, WIDTH / 200, HEIGHT)
  mapModule.right = mapModule.collisionEngine.rectangle(WIDTH * 199 / 200, 0, WIDTH / 200, HEIGHT)

  -- shapes are stored directly as a HC shape, TODO change this later
  mapModule.rectangle = {
    ax = WIDTH/4,
    ay = HEIGHT/2,
    width = 3 * WIDTH / 10,
    height = 3 * HEIGHT / 10}
  mapModule.rectangle.bbColl = mapModule.collisionEngine.rectangle(mapModule.rectangle.ax, mapModule.rectangle.ay, mapModule.rectangle.width, mapModule.rectangle.height)
  mapModule.rectangle.bbColl:rotate(1)

  mapModule.rectangle2 = {
    ax = WIDTH/4 - 3 * WIDTH / 20,
    ay = HEIGHT/2,
    width = WIDTH / 10,
    height = 3 * HEIGHT / 10}
  mapModule.rectangle2.bbColl = mapModule.collisionEngine.rectangle(mapModule.rectangle2.ax, mapModule.rectangle2.ay, mapModule.rectangle2.width, mapModule.rectangle2.height)

  mapModule.circle = {
    cx = WIDTH / 2,
    cy = HEIGHT / 2,
    radius = HEIGHT / 4
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
