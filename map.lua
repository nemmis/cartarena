local colors = require 'color'

local mapModule = {}
local mapClass = {}

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()
local PLAYER_COUNT = 4 -- each map can handle up to four players

local function addMapElements(map)
  assert(map)

  -- enforce map boundaries
  local boundaryWidth = 500
  local visibleWidth = HEIGHT / 100
  map.up = mapModule.collisionEngine.rectangle(0, -boundaryWidth + visibleWidth, WIDTH, boundaryWidth)
  map.down = mapModule.collisionEngine.rectangle(0, HEIGHT - visibleWidth, WIDTH, boundaryWidth)
  map.left = mapModule.collisionEngine.rectangle(-boundaryWidth + visibleWidth, 0, boundaryWidth, HEIGHT)
  map.right = mapModule.collisionEngine.rectangle(WIDTH - visibleWidth, 0, boundaryWidth, HEIGHT)

  -- shapes are stored directly as a HC shape, TODO change this later
  map.rectangle = {
    ax = 4* WIDTH/12,
    ay = 3 * HEIGHT/8,
    width = 3 * WIDTH / 10,
    height = 3 * HEIGHT / 10}
  map.rectangle.bbColl = mapModule.collisionEngine.rectangle(map.rectangle.ax, map.rectangle.ay, map.rectangle.width, map.rectangle.height)
  map.rectangle.bbColl:rotate(1)

  map.rectangle2 = {
    ax = WIDTH/4 - 3 * WIDTH / 20,
    ay = HEIGHT/2,
    width = WIDTH / 12,
    height = 3 * HEIGHT / 12}
  map.rectangle2.bbColl = mapModule.collisionEngine.rectangle(map.rectangle2.ax, map.rectangle2.ay, map.rectangle2.width, map.rectangle2.height)

  map.circle = {
    cx = 3* WIDTH / 4,
    cy = 2* HEIGHT / 7,
    radius = HEIGHT / 7
  }
  map.circle.bbColl = mapModule.collisionEngine.circle(map.circle.cx, map.circle.cy, map.circle.radius)

  --local bigRadius = HEIGHT / 4
  --local smallRadius = WIDTH * 3 / 32

  -- circle in the center
  -- love.graphics.circle("line", WIDTH / 2, HEIGHT / 2, bigRadius)
end

function mapModule.newMap()
  local map = {}

  addMapElements(map)

  setmetatable(map, {__index = mapClass})

  return map
end

function mapModule.init(collisionEngine)
  assert(collisionEngine, "The collision engine must be specified when initializing the map module")
  mapModule.collisionEngine = collisionEngine
end

----------------------------------------------
-- Get the starting positions of the players
-- @return a position, table with key x, y and theta
----------------------------------------------
function mapClass:getStartingPositions()
  local startingPositions = {
    {x = 50, y = 50, theta = -1 / 4 * math.pi },
    {x = WIDTH - 50, y = HEIGHT - 50, theta = 3 / 4 * math.pi},
    {x = WIDTH - 50, y = 50, theta = 1 / 4 * math.pi },
    {x = 50, y = HEIGHT -50, theta = -3 / 4 * math.pi }
  }

  assert(#startingPositions == PLAYER_COUNT, string.format("A map must be able to handle %i players", PLAYER_COUNT))

  return startingPositions
end


-----------------------
-- Draw a map
-----------------------
function mapClass:draw()

  love.graphics.setColor(colors.TURQUESE())

  -- boundaries
  self.up:draw()
  self.down:draw()
  self.right:draw()
  self.left:draw()
  self.rectangle.bbColl:draw()
  self.rectangle2.bbColl:draw()
  self.circle.bbColl:draw()

end


return mapModule
