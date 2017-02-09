-- Bullet
-- Kill players when colliding with them
-- Bounce on map elements
local geometry = require 'geometryLib'
local color = require 'color'

local bulletModule = {}

local bulletClass = {}
local BULLET_SPEED_NORM = 800
local BULLET_RADIUS = 15

function bulletModule.init(collisionDetection)
  bulletClass.collisionDetection = collisionDetection
end

function bulletModule.new(x0, y0, vxDir, vyDir)
  --TODO make sure that the speed direction is not the null vector
  local vx0, vy0 = geometry.normalize(vxDir, vyDir, BULLET_SPEED_NORM)
  local bullet = { x = x0, y = y0, radius = BULLET_RADIUS, vx = vx0, vy = vy0}

  -- register the collision shape
  bullet.collisionShape = bulletClass.collisionDetection.circle(bullet.x, bullet.y, bullet.radius)

  setmetatable(bullet, {__index = bulletClass} )

  return bullet
end

local function getNewSpeed(vx0, vy0, sepX1, sepY1)

  -- scale for better numeric stability
  local sepX, sepY = geometry.scale(sepX1, sepY1, 10)

  local vx0P = -vx0
  local vy0P = -vy0

  -- TODO introduce friction and bounciness ?
  local vDotSep = geometry.dot(vx0P, vy0P, sepX, sepY)
  local sepNorm = geometry.getNorm(sepX, sepY)

  -- component along the separation vector
  local vSepX = vDotSep * sepX / (sepNorm * sepNorm)
  local vSepY = vDotSep * sepY / (sepNorm * sepNorm)

  -- component orthogonal to separation vector
  local vOrthoSepX, vOrthoSepY = geometry.addVector(vSepX, vSepY, vx0, vy0)

  local v1x, v1y = geometry.addVector(vSepX, vSepY, vOrthoSepX, vOrthoSepY)
  return geometry.normalize(v1x, v1y, BULLET_SPEED_NORM)

end

local function updateState(bullet, dt)
  -- the speed is constant
  local x1 = bullet.x + bullet.vx * dt
  local y1 = bullet.y + bullet.vy * dt

  bullet.x = x1
  bullet.y = y1

  -- update collision engine
  bullet.collisionShape:moveTo(x1, y1)
end

function bulletClass:update(dt)
  -- STATE UPDATE
  -- update the state of the bullet, might reach an invalid state
  updateState(self, dt)

  -- COLLISION DETECTION
  -- test for collisions
  local collisions = self.collisionDetection.collisions(self.collisionShape)
  local isColliding = false
  local sepX, sepY = 0, 0
  for otherShape, separationVector in pairs(collisions) do
    isColliding = true
    sepX = sepX + separationVector.x
    sepY = sepY + separationVector.y
  end

  -- COLLISION RESPONSE: position and speed
  -- if there is a collision, compute the new speed
  local v1x, v1y = self.vx, self.vy
  if isColliding then
    v1x, v1y = getNewSpeed(self.vx, self.vy, sepX, sepY)
  end

  -- update the speed
  self.vx = v1x
  self.vy = v1y
  self.collisionShape:moveTo(self.x, self.y)

  -- update the position with separation vector
  local x1 = self.x + sepX
  local y1 = self.y + sepY
end

function bulletClass:draw()
  love.graphics.setColor(color.ORANGE())
  self.collisionShape:draw()
  --love.graphics.circle("line", self.x, self.y, self.radius)

  love.graphics.setColor(color.GREEN())
  --love.graphics.line(self.x, self.y, self.x + self.vx, self.y + self.vy)


end


return bulletModule
