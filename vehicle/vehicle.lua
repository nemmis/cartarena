local geometryLib = require 'geometryLib'
local color = require "color"

local vehicleModule = {}

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

-- TODO move constants to the prototype ?
local PLAYER_ACCELERATION = 800 -- Px sec-2
local PLAYER_BREAK = 800
local PLAYER_MAX_SPEED = 350 -- Px sec-1
local PLAYER_FRICTION = -3 -- Px sec-1
local PLAYER_ROTATION_SPEED = 3 -- rad sec-1
local boundingRadius = 30

-- the prototype holds the behaviour
local vehiclePrototype = {}

-- initialize the dependencies
function vehicleModule.init(collisionDetectionModuleIn)
  vehiclePrototype.staticCollisionDetectionModule = collisionDetectionModuleIn
end

-- debug is optional
function vehicleModule.new(x0, y0, theta0, debugging)

  -- the instance holds the state
  local vehicle = {
    x = x0,
    y = y0,
    theta = theta0,
    vx = 0,
    vy = 0,
    bbCollision = vehiclePrototype.staticCollisionDetectionModule.circle(x0, y0, boundingRadius),
    -- collision response type
    collisionResponseType = "separating",
    -- sum of all separation vector
    separationVectorX = 0,
    separationVectorY = 0,
    -- all the separation vector at a given frame
    separationVectors = {},
    debug = debugging or false
  }

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

-- then all the functions are methods
-- accelerates and breaks in [0 1]
-- steers in [-1 1] (left, right)
function vehiclePrototype:update(dt, accelerates, breaks, steers)

  -- find the candidate next state
  local x0, y0, theta0 = self.x, self.y, self.theta
  local x1, y1, theta1, vx1, vy1 = getNewState(dt, accelerates, breaks, steers, self.x, self.y, self.theta, self.vx, self.vy)

  ----------------------------
  -- Collision detection
  ----------------------------

  -- use the collision detection engine to see if there is a collision with the new position and get the separation vector
  local collide = false
  local separationX, separationY = 0, 0

  -- reiitialize separation vectors
  for k in pairs (self.separationVectors) do
    self.separationVectors[k] = nil
  end

  self.bbCollision:moveTo(x1, y1)
  self.bbCollision:setRotation(theta1)

  local collisions = self.staticCollisionDetectionModule.collisions(self.bbCollision)

  for shape, separatingVector in pairs(collisions) do
    collide = true
    separationX = separationX + separatingVector.x
    separationY = separationY + separatingVector.y

    -- store each separation vector for debugging purpose
    local cx, cy = shape:center()
    table.insert(self.separationVectors, {cx = cx, cy = cy, vecX = separatingVector.x, vecY = separatingVector.y})
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
  -- can be inaccurate for high speed when distance between two states is high
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
end

function vehiclePrototype:draw()
  --TODO use transformation push / pop

  -- draw player
  love.graphics.setColor(color.ORANGE())

  -- line for the player in Px
  -- be careful player.x, player.y should be the center of gravity
  local ax, ay = geometryLib.localToGlobalPoint(0, 20, self.x, self.y, self.theta)
  local bx, by = geometryLib.localToGlobalPoint(10, -10, self.x, self.y, self.theta)
  local cx, cy = geometryLib.localToGlobalPoint(-10, -10, self.x, self.y, self.theta)
  love.graphics.line(ax, ay, bx, by, cx, cy, ax, ay)

  if self.debug
  then
    -- position
    love.graphics.setColor(color.WHITE())
    love.graphics.circle("line", self.x, self.y, 5)

    -- speed
    love.graphics.setColor(0, 255, 0)
    love.graphics.line(self.x, self.y, self.x + self.vx, self.y + self.vy)

    -- local coordinate system
    love.graphics.setColor(255, 0, 0)
    xAxisVectorGlobalDx, xAxisVectorGlobalDy = geometryLib.localToGlobalVector(20, 0, self.x, self.y, self.theta)
    love.graphics.line(self.x, self.y, self.x + xAxisVectorGlobalDx, self.y + xAxisVectorGlobalDy)

    love.graphics.setColor(0, 0, 255)
    yAxisVectorGlobalDx, yAxisVectorGlobalDy = geometryLib.localToGlobalVector(0, 20, self.x, self.y, self.theta)
    love.graphics.line(self.x, self.y, self.x + yAxisVectorGlobalDx, self.y + yAxisVectorGlobalDy)

    -- bounding box
    self.bbCollision:draw()

    -- resulting separatingVector
    love.graphics.setColor(color.ORANGE())
    local scale = 20
    love.graphics.line(self.x, self.y, self.x + self.separationVectorX * scale, self.y + self.separationVectorY * scale)

    -- all separating vectors
    for _, data in ipairs(self.separationVectors) do
      local scale = 8
      love.graphics.line(data.cx, data.cy, data.cx + data.vecX * scale, data.cy + data.vecY * scale)
    end
  end
end

function vehiclePrototype:setDebug(debugging)
  self.debug = debugging

end

return vehicleModule
