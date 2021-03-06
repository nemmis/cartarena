--[[

A vehicle

- knows a set of HitEventListeners that have registered for HitEvents

= Driving requirements

- Player can accelerate, break, steer (right / left)
- The vehicle stops if the player does not accelerate (friction)
- TODO boost
- TODO go backward, is it needed ?

== Collisions requirements
Method0: use the separation vector to correct the vehicle position
the bounding shape needs to be a circle as rotation cannot be corrected
the speed is not corrected

Method2: if a collision occurs, set the speed to 0 and keep the old valid position
a bit rough, works with a rectangle as we prevent illegal states to happen

== Shooting
- the player has an initial set of bullets
- when the right bumper of the gamepad is pressed, then the player fires a bullet
- the player can only fire if a bullet is available

== Picking up bullets
- the player can pick up bullets by moving over bullets that have stopped (pickable bullets)
- bullets that are picked up can be fired
- the player can pick up as many bullets as possible

== Being hit
- when a player is hit by a bullet it sends a HitEvent to all its HitEventsListeners
- a player is eliminated when its vehicle is hit
- a vehicle can be hit by its own bullets
- a bullet can hit several vehicles, it does not bounce on the vehicle it hits (would it be more consistent to bounce ?)
- when a vehicle is hit, its bullets cannot be picked (they could also be transferred immediately to the player that shot this bullet or be dropped and become pickable for anybody)
  it is always guaranteed that there is at least one bullet remaining so the round can be finished
- a hit vehicle cannot move and is an obstacle for other vehicles (but bullet go through)

--]]

local geometryLib = require 'geometryLib'
local colorModule = require 'color'
local trajectoryModule = require 'trajectory'
local bulletModule = require 'bullet'
local collisionHelpers = require 'collisionHelpers'
local bulletModule = require 'bullet'
local liveBulletRegistryModule = require 'liveBulletsRegistry'
local utils = require 'utils'
local graphicsHelpers = require 'graphicsHelpers'
local isHitEventModule = require 'isHitEvent'

local vehicleModule = {}

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

local PLAYER_ACCELERATION = 800 -- Px sec-2
local PLAYER_BREAK = 800
local PLAYER_MAX_SPEED = 450 -- Px sec-1
local PLAYER_FRICTION = -3 -- Px sec-1
local PLAYER_ROTATION_SPEED = 5 -- rad sec-1
local boundingRadius = 20
local INITIAL_BULLET_COUNT = 3

-- the prototype holds the behaviour
local vehiclePrototype = {}

--------------------------------------------------
-- Create a vehicle collision shape
--------------------------------------------------
local function newPlayerCollisionShape(cx, cy, radius, collider)
  local collisionShape = collider:circle(cx, cy, boundingRadius)
  collisionShape.isAVehicle = true  -- a key to recognize that the collision shape is the one of a vehicle
  return collisionShape
end

--------------------------------------------------
-- Create a vehicle
-- @param debug is optional
--------------------------------------------------
function vehicleModule.new(character, x0, y0, theta0, bulletRegistry, collider, debugging)
  utils.assertTypeTable(character)
  utils.assertTypeNumber(x0)
  utils.assertTypeNumber(y0)
  utils.assertTypeNumber(theta0)
  utils.assertTypeTable(bulletRegistry)
  utils.assertTypeTable(collider)
  utils.assertTypeOptionalBoolean(debugging)

  local debugging = debugging or false

  -- the instance holds the state
  local vehicle = {
    character = character,
    x = x0,
    y = y0,
    theta = theta0,
    vx = 0,
    vy = 0,
    bullets = {}, -- handled as a stack
    bulletRegistry = bulletRegistry,
    shotRequest = false, -- we assume that there cannot be more than one shot request between two frames
    outOfService = false,
    isHitEventListeners = {}, -- an array of hit event listeners
    trajectory = trajectoryModule.new(),
    collider = collider,
    bbCollision = newPlayerCollisionShape(x0, y0, boundingRadius, collider),
    color = character:getColor(),
    -- collision response type
    collisionResponseType = "separating",
    -- sum of all separation vector
    separationVectorX = 0,
    separationVectorY = 0,
    -- all the separation vector at a given frame
    separationVectors = {},
    debug = debugging
  }

  -- add bullets
  for i = 1, INITIAL_BULLET_COUNT do
    table.insert(vehicle.bullets, bulletModule.newPickedBullet(character, collider, debugging))
  end

  -- behaviour is defined in the prototype
  setmetatable(vehicle, {__index = vehiclePrototype})

  return vehicle
end

-- return new position, orientation, speed
local function getNewState(dt, accelerates, breaks, steers, x0, y0, theta0, vx0, vy0)

  -- compute acceleration factor
  local accelerationFactor = 0
  if accelerates > 0
    then accelerationFactor = accelerates * PLAYER_ACCELERATION
  elseif breaks > 0
    then accelerationFactor = -breaks * PLAYER_BREAK
  end

  local v0Norm = geometryLib.getNorm(vx0, vy0)

  -- find the norm of the speed
  -- speed norm bounded between 0 and PLAYER_MAX_SPEED
  -- the speed is always in the direction of the local Y axis at the start of an update loop
  local newSpeedNorm = v0Norm + accelerationFactor * dt + PLAYER_FRICTION
  if newSpeedNorm > PLAYER_MAX_SPEED
    then newSpeedNorm = PLAYER_MAX_SPEED
  elseif newSpeedNorm < 0
    then newSpeedNorm = 0
  end

  -- find the speed direction, potentially rotated
  -- for floating point values
  -- could simplify the code by introducing a speed direction
  -- we have the formula if old speed is not null vector, if vehicle is stopped then it is the Y axis of the local coordinate system
  local newSpeedDirXNormalized, newSpeedDirYNormalized = geometryLib.localToGlobalVector(0, 1, x0, y0, theta0)
  local thetaDelta = 0
  if newSpeedNorm > 0	and steers ~= 0 -- if the speed norm is null, the speed is the null vector (and hence does not need to be rotated)
  then
    thetaDelta = steers * PLAYER_ROTATION_SPEED * dt
    newSpeedDirXNormalized, newSpeedDirYNormalized = geometryLib.rotate(newSpeedDirXNormalized, newSpeedDirYNormalized, thetaDelta)
  end

  -- compute the new speed vector from the direction and norm (newSpeed norm might be null)
  local newSpeedX = newSpeedNorm * newSpeedDirXNormalized
  local newSpeedY = newSpeedNorm * newSpeedDirYNormalized

  -- compute the new position
  local newPositionX = x0 + newSpeedX * dt
  local newPositionY = y0 + newSpeedY * dt

  --compute the new orientation
  local newTheta = theta0 + thetaDelta

  return newPositionX, newPositionY, newTheta, newSpeedX, newSpeedY
end

local function updateVehicleState(vehicle, x, y, theta, vx, vy)
  -- collision engine
  vehicle.bbCollision:moveTo(x, y)
  vehicle.bbCollision:setRotation(theta)
  vehicle.x = x
  vehicle.y = y
  vehicle.theta = theta
  vehicle.vx = vx
  vehicle.vy = vy
end

--------------------------------------------------------------
-- Does the vehicle have bullets ?
-- @return a boolean that indicates if a player has bullets
--------------------------------------------------------------
function vehiclePrototype:hasBullets()
  return self:getBulletCount() > 0
end

--------------------------------
-- Get the number of bullets
--------------------------------
function vehiclePrototype:getBulletCount()
  return #self.bullets
end

------------------------------------
-- Shoot a bullet
-- during the next update, at most one bullet can be shot by game loop
------------------------------------
function vehiclePrototype:shoot()
  self.shotRequest = true
end

-- @return the starting position and speed direction of a bullet
-- the bullet is fired along the local Y axis
local function getBulletStartingPositionAndSpeedDirection(vehicle)
  local x, y = geometryLib.localToGlobalPoint(0, boundingRadius + bulletModule.getBulletRadius() + 1, vehicle.x, vehicle.y, vehicle.theta)
  local vxDir, vyDir = geometryLib.localToGlobalVector(0, 1,  vehicle.x, vehicle.y, vehicle.theta)
  return x, y, vxDir, vyDir
end

-- @brief Shoot a bullet in the local Y direction if a bullet is available
local function processShootRequest(vehicle)
  if not vehicle:hasBullets() then return end;

  local firedBullet = table.remove(vehicle.bullets)

  -- fire the bullet
  local bulletX, bulletY, bulletVx, bulletVy = getBulletStartingPositionAndSpeedDirection(vehicle)
  firedBullet:fire(bulletX, bulletY, bulletVx, bulletVy)
  vehicle.bulletRegistry:addFiredBullet(firedBullet)

  return true
end

----------------------------------------------------------
-- @brief pick up a bullet
-- the bullet must be pickable
-- remove the bullet from the live bullet registry
-- add the bullet to the player bullet set
----------------------------------------------------------
local function pickUpBullet(vehicle, bullet)
  utils.assertTypeTable(vehicle)
  utils.assertTypeTable(bullet)
  bullet:pickUp(vehicle.character)
  vehicle.bulletRegistry:removePickedBullet(bullet)
  table.insert(vehicle.bullets, bullet)
end

---------------------------------------------------
-- Indicates if a vehicle is out of service
---------------------------------------------------
function vehiclePrototype:isOutOfService()
  return self.outOfService
end

---------------------------------------------------
-- Send a hit event to all isHitEventListeners
---------------------------------------------------
local function sendHitEvent(vehicle, bullet)
  utils.assertTypeTable(vehicle)
  utils.assertTypeTable(bullet)

  local target = vehicle.character
  local shooter = bullet:getOwner()
  local isHitEvent = isHitEventModule.newIsHitEvent(target, shooter)

  for _, listener in ipairs(vehicle.isHitEventListeners) do
    listener:processIsHitEvent(isHitEvent)
  end
end

----------------------------------------------------------------------------
-- @brief Handles vehicle vs bullet collisions
-- @return a boolean that indicates if the vehicle is out of service
-- A vehicle vs bullet collision results in either:
--  - the bullet being picked up by the vehicle
--  - the vehicle is out of service and a HitEvent is sent
----------------------------------------------------------------------------
local function handleVehicleBulletCollisions(vehicle)

  local collisions = vehicle.collider:collisions(vehicle.bbCollision)

  for otherShape, separatingVector in pairs(collisions) do
    if collisionHelpers.isVehicleBulletCollision(vehicle.bbCollision, otherShape) then
      local bullet = otherShape.bullet
      -- either the vehicle can pick up the bullet or it is out-of-service
      if bullet:isPickable() then
        -- TODO return the bullet outside of the function
        pickUpBullet(vehicle, bullet)
        return false
      else
        sendHitEvent(vehicle, bullet)
        return true
      end
    end
  end
end

-- @brief update loop for a vehicle
-- @in accelerates and breaks in [0 1]
-- @in steers in [-1 1] (left, right)
-- a bullet object does not react on bullet vs player collisions
function vehiclePrototype:update(dt, accelerates, breaks, steers)

  -- do nothing if the vehicle is out of service
  if self:isOutOfService() then return end

  -- vehicle vs bullet collision handing
  if handleVehicleBulletCollisions(self) then
    self.outOfService = true
    return
  end

  -- find the candidate next state
  local x0, y0, theta0 = self.x, self.y, self.theta
  local x1, y1, theta1, vx1, vy1 = getNewState(dt, accelerates, breaks, steers, self.x, self.y, self.theta, self.vx, self.vy)

  ----------------------------
  -- Collision detection
  ----------------------------

  -- use the collision detection engine to see if there is a collision with the new position and get the separation vector
  local collide = false
  local separationX, separationY = 0, 0

  -- reiitialize debugging separation vectors
  for k in pairs (self.separationVectors) do
    self.separationVectors[k] = nil
  end

  -- move to the candidate next state, possible collisions
  self.bbCollision:moveTo(x1, y1)
  self.bbCollision:setRotation(theta1)

  local collisions = self.collider:collisions(self.bbCollision)

  -- only consider collisions with map elements
  for shape, separatingVector in pairs(collisions) do
    -- ignore player vs bullet collisions
    if  not collisionHelpers.isVehicleBulletCollision(self.bbCollision, shape) then
      collide = true
      separationX = separationX + separatingVector.x
      separationY = separationY + separatingVector.y

      -- store each separation vector for debugging purpose
      local cx, cy = shape:center()
      table.insert(self.separationVectors, {cx = cx, cy = cy, vecX = separatingVector.x, vecY = separatingVector.y})
    end
  end

  -- store the resulting separation vector for debugging purpose
  self.separationVectorX = separationX
  self.separationVectorY = separationY

  -- move back the collision shape
  self.bbCollision:moveTo(x0, y0)
  self.bbCollision:setRotation(theta0)

  ----------------------------
  -- Collision response
  ----------------------------

  -- if there is a collision don't move the vehicle and set the speed to zero
  -- can be inaccurate for high speed when distance between two states is high (for example stopping before an obstacle)
  if self.collisionResponseType == "validStates" then
    if collide then
      self.vx = 0
      self.vy = 0
    else
      -- update the player
      updateVehicleState(self, x1, y1, theta1, vx1, vy1)
    end
  else -- separating vectors
      updateVehicleState(self, x1 + separationX, y1 + separationY, theta1, vx1, vy1)
  end

  self.trajectory:add(self.x, self.y)

  -- Shooting
  -- Shoot a bullet after updating the position of the player
  -- In the game loop, bullet update is happening after the vehicle update
  if self.shotRequest then
    processShootRequest(self)
    self.shotRequest = false
  end
end

--------------------------------------
-- Register a HitEventListener
-- @param an object that has a function called processHitEvent with prototype (target : Character, shooter : Character)
--------------------------------------
function vehiclePrototype:registerIsHitEventListener(isHitEventListener)
  isHitEventModule.assertTypeIsHitEventListener(isHitEventListener)
  table.insert(self.isHitEventListeners, isHitEventListener)
end

function vehiclePrototype:draw()
  --TODO use transformation push / pop

  graphicsHelpers.smallPrint()

  -- draw player
  love.graphics.setColor(colorModule.getRGB(self.color))
  if self:isOutOfService() then
    love.graphics.setColor(colorModule.GREY(125))
  end

  -- bounding shape
  self.bbCollision:draw()
  local xLocal, yLocal = geometryLib.localToGlobalVector(0, boundingRadius, self.x, self.y, self.theta)
  --love.graphics.setLineWidth(2)
  love.graphics.line(self.x, self.y, self.x + xLocal, self.y + yLocal)
  --love.graphics.setLineWidth(1)

  -- number of bullets
  love.graphics.print(self:getBulletCount(), self.x + 15, self.y + 15)

  if self.debug then
    -- position
    love.graphics.setColor(colorModule.WHITE())
    love.graphics.circle("line", self.x, self.y, 5)

    -- trajectory
    self.trajectory:draw()

    -- speed, scale it
    love.graphics.setColor(0, 255, 0)
    love.graphics.line(self.x, self.y, self.x + self.vx / 10, self.y + self.vy / 10)

    -- local coordinate system
    love.graphics.setColor(255, 0, 0)
    local xAxisVectorGlobalDx, xAxisVectorGlobalDy = geometryLib.localToGlobalVector(20, 0, self.x, self.y, self.theta)
    love.graphics.line(self.x, self.y, self.x + xAxisVectorGlobalDx, self.y + xAxisVectorGlobalDy)

    love.graphics.setColor(0, 0, 255)
    local yAxisVectorGlobalDx, yAxisVectorGlobalDy = geometryLib.localToGlobalVector(0, 20, self.x, self.y, self.theta)
    love.graphics.line(self.x, self.y, self.x + yAxisVectorGlobalDx, self.y + yAxisVectorGlobalDy)

    -- resulting separatingVector
    love.graphics.setColor(colorModule.ORANGE())
    local scale = 20
    love.graphics.line(self.x, self.y, self.x + self.separationVectorX * scale, self.y + self.separationVectorY * scale)

    -- all separating vectors for each shape the player collides with
    for _, data in ipairs(self.separationVectors) do
      local scale = 8
      love.graphics.line(data.cx, data.cy, data.cx + data.vecX * scale, data.cy + data.vecY * scale)
    end
  end
end

---------------------------------------
-- Returns the position of a vehicle
---------------------------------------
function vehiclePrototype:position()
  return self.x, self.y
end

function vehiclePrototype:setDebug(debugging)
  self.debug = debugging
  for _, bullet in pairs(self.bullets) do
    bullet:setDebug(debugging)
  end
end

return vehicleModule
