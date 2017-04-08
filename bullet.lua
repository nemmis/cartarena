--[[ Bullet

Kill players when colliding with them
Bounce on map elements
A bullet has an owner. The owner changes when a bullet is picked up.
One use case of the owner is to find out who has shot a bullet.

]]


local geometry = require 'geometryLib'
local color = require 'color'
local trajectoryModule = require 'trajectory'
local timerModule = require 'timer'
local collisionHelpers = require 'collisionHelpers'
local utils = require 'utils'

local bulletModule = {}
local bulletClass = {}

local BULLET_SPEED_NORM = 800
local BULLET_RADIUS = 7
local BULLET_TTL_SEC = 1

-- the three states of a bullet
local BULLET_PICKED, BULLET_MOVING, BULLET_STOPPED = "BULLET_PICKED", "BULLET_MOVING", "BULLET_STOPPED"

-- @return the constant radius of a bullet
function bulletModule.getBulletRadius()
  return BULLET_RADIUS
end

-----------------------------------------------------
-- @brief Bullet constructor
-- @param owner (type character) the owner of a bullet
-- @param collider  a collision engine instance
-- @param debug is optional, false by default
-----------------------------------------------------
function bulletModule.newPickedBullet(owner, collider, debug)
  utils.assertTypeTable(owner)
  utils.assertTypeTable(collider)
  utils.assertTypeOptionalBoolean(debug)

  local debugging = debug or false

  local bullet = {
    owner = owner,
    state = BULLET_PICKED,
    radius = BULLET_RADIUS,
    x = 0,
    y = 0,
    vx = 0,
    vy = 0,
    collider = collider,
    collisionShape = nil, -- collision shape not registered yet
    trajectory = trajectoryModule.new(), -- TODO trajectory not needed when the bullet is picked
    timerTTL = timerModule.new(BULLET_TTL_SEC * 1000),
    debugging = debugging
  }

  setmetatable(bullet, {__index = bulletClass} )

  return bullet
end

-- @brief create a bullet collision shape
local function newBulletCollisionShape(cx, cy, radius, bullet, collider)
  local collisionShape = collider:circle(cx, cy, radius)
  collisionShape.isABullet = true  -- a key to recognize that the collision shape is the one of a vehicle
  collisionShape.bullet = bullet
  return collisionShape
end

-- @brief Fire a bullet
-- state becomes BULLET_MOVING
-- initializes position, speed and handle collisions
function bulletClass:fire(x0, y0, vxDir, vyDir)

  if self.state ~= BULLET_PICKED then return end

  --TODO make sure that the speed direction is not the null vector
  local vx0, vy0 = geometry.normalize(vxDir, vyDir, BULLET_SPEED_NORM)
  self.x = x0
  self.y = y0
  self.vx = vx0
  self.vy = vy0
  self.collisionShape = newBulletCollisionShape(self.x, self.y, self.radius, self, self.collider)

  -- create a new trajectory
  self.trajectory = trajectoryModule.new()

  self.timerTTL:stop()
  self.timerTTL:reset()
  self.timerTTL:start()
  self.state = BULLET_MOVING
end

-- @brief Indicates that a bullet can be picked
function bulletClass:isPickable()
  return self.state == BULLET_STOPPED
end

--------------------------------
-- @brief Pick up a bullet
-- @param newOwner  type character, the new owner of a bullet
-- state becomes PICKED
-- the ownership changes
--------------------------------
function bulletClass:pickUp(newOwner)
  utils.assertTypeTable(newOwner)

  -- a bullet can only be picked if the state is STOPPED
  if self.state ~= BULLET_STOPPED then return end

  self.owner = newOwner

  -- unregister from collision detection engine
  self.collider:remove(self.collisionShape)
  self.collisionShape = nil

  self.timerTTL:stop()
  self.timerTTL:reset()
  self.state = BULLET_PICKED
end

-- typically called when the timerTTL has elapsed
local function stopBullet(bullet)
  -- a bullet can only be stopped when the timerTTL has elapsed and the state is MOVING
  -- TODO add assertion for these conditions
  bullet.vx = 0
  bullet.vy = 0
  bullet.state = BULLET_STOPPED
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

  -- nothing to update if the bullet is picked
  if self.state == BULLET_PICKED then return end

  -- update the TTL timer to know when the bullet will stop
  self.timerTTL:update(dt)

  -- stop the bullet if needed
  if self.timerTTL:isElapsed() then
    stopBullet(self)
  end

  -- at this point the bullet is MOVING or has STOPPED

  -- STATE UPDATE
  -- update the state of the bullet, might reach an invalid state
  updateState(self, dt)

  -- COLLISION DETECTION: bouncing when meeting map elements
  -- test for collisions
  local collisions = self.collider:collisions(self.collisionShape)
  local isColliding = false
  local sepX, sepY = 0, 0

  -- solve bullet vs map collisions
  for otherShape, separationVector in pairs(collisions) do
    if not collisionHelpers.isVehicleBulletCollision(self.collisionShape, otherShape) then
      isColliding = true
      sepX = sepX + separationVector.x
      sepY = sepY + separationVector.y
    end
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

  -- update the position with separation vector
  local x1 = self.x + sepX
  local y1 = self.y + sepY
  self.x = x1
  self.y = y1
  self.collisionShape:moveTo(x1, y1)

  -- trajectory
  self.trajectory:add(x1, y1)

end

-----------------------------------------
-- Get the owner of a bullet
-- @return owner, type Character
-----------------------------------------
function bulletClass:getOwner()
  utils.assertTypeTable(self.owner)
  return self.owner
end

-- different colors for the different states
function bulletClass:draw()
  assert(self.state ~= BULLET_PICKED, "Should not attempt to draw a bullet that is picked")

  local r,g,b = color.ORANGE()
  if self.state == BULLET_STOPPED then
    r, g, b = color.GREEN()
  end
  love.graphics.setColor(r, g, b)

  self.collisionShape:draw()

  if self.debugging then
    -- display the owner
    love.graphics.print(self.owner:getName(), self.x + BULLET_RADIUS, self.y + BULLET_RADIUS)

    self.trajectory:draw()
  end

end

function bulletClass:setDebug(debugging)
  self.debugging = debugging
end


return bulletModule
