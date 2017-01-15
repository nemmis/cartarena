local geometryLib = require 'geometryLib'
local color = require "color"

local vehicleModule = {}

local PLAYER_ACCELERATION = 800 -- Px sec-2
local PLAYER_BREAK = 800
local PLAYER_MAX_SPEED = 350 -- Px sec-1
local PLAYER_FRICTION = -3 -- Px sec-1
local PLAYER_ROTATION_SPEED = 3 -- rad sec-1

-- the prototype holds the behaviour
local vehiclePrototype = {}

function vehicleModule.new(x0, y0, theta0)
  -- the instance holds the state
  local vehicle = {x = x0, y = y0, theta = theta0, vx = 0, vy = 0}

  -- behaviour is defined in the prototype
  setmetatable(vehicle, {__index = vehiclePrototype})

  return vehicle
end

-- then all the functions are methods
-- accelerates and breaks in [0 1]
-- steers in [-1 1] (left, right)
function vehiclePrototype:update(dt, accelerates, breaks, steers)

  local accelerationFactor = 0
	if accelerates > 0
		then accelerationFactor = accelerates * PLAYER_ACCELERATION
	elseif breaks > 0
		then accelerationFactor = -breaks * PLAYER_BREAK
	end

	local x1 = self.x
	local y1 = self.y
	local v1x = self.vx
	local v1y = self.vy
	local theta1 = self.theta
	local v1Norm = geometryLib.getNorm(v1x, v1y)

  -- find the norm of the speed
  -- speed norm bounded between 0 and PLAYER_MAX_SPEED
  -- the speed is always in the direction of the local Y axis at the start of an update loop
	local newSpeedNorm = v1Norm + accelerationFactor * dt + PLAYER_FRICTION
	if newSpeedNorm > PLAYER_MAX_SPEED
		then newSpeedNorm = PLAYER_MAX_SPEED
	elseif newSpeedNorm < 0
		then newSpeedNorm = 0
	end

	-- find the speed direction, potentially rotated
	-- for floating point values
	-- could simplify the code by introducing a speed direction
  -- we have the formula if old speed is not null vector, if vehicle is stopped then it is the Y axis of the local coordinate system
	local newSpeedDirXNormalized, newSpeedDirYNormalized = geometryLib.localToGlobalVector(0, 1, x1, y1, theta1)
	local thetaDelta = 0
	if newSpeedNorm > 0	and steers ~= 0 -- if the speed norm is null, the speed is the null vector (and hence does not need to be rotated)
	then
  	thetaDelta = steers * PLAYER_ROTATION_SPEED * dt
  	newSpeedDirXNormalized, newSpeedDirYNormalized = geometryLib.rotate(newSpeedDirXNormalized, newSpeedDirYNormalized, thetaDelta)
	end

	-- compute the new speed vector from the direction and norm (newSpeed norm might be null)
	newSpeedX = newSpeedNorm * newSpeedDirXNormalized
	newSpeedY = newSpeedNorm * newSpeedDirYNormalized

  -- compute the new position
	local newPositionX = x1 + newSpeedX * dt
	local newPositionY = y1 + newSpeedY * dt

	-- update the player
	self.x = newPositionX
	self.y = newPositionY
	self.vx = newSpeedX
	self.vy = newSpeedY
	self.theta = self.theta + thetaDelta
end

function vehiclePrototype:draw()
  --TODO use transformation push / pop

  -- draw player
  love.graphics.setColor(colors.ORANGE())

  -- line for the player in Px
  -- be careful player.x, player.y should be the center of gravity
  local ax, ay = geometryLib.localToGlobalPoint(0, 20, self.x, self.y, self.theta)
  local bx, by = geometryLib.localToGlobalPoint(10, -10, self.x, self.y, self.theta)
  local cx, cy = geometryLib.localToGlobalPoint(-10, -10, self.x, self.y, self.theta)
  love.graphics.line(ax, ay, bx, by, cx, cy, ax, ay)

  if globalDebugFlag
  then
    -- self position
    love.graphics.setColor(colors.WHITE())
    love.graphics.circle("line", self.x, self.y, 5)

    -- display speed in green
    love.graphics.setColor(0, 255, 0)
    love.graphics.line(self.x, self.y, self.x + self.vx, self.y + self.vy)

    -- coordinates system
    love.graphics.setColor(255, 0, 0)
    xAxisVectorGlobalDx, xAxisVectorGlobalDy = geometryLib.localToGlobalVector(20, 0, self.x, self.y, self.theta)
    love.graphics.line(self.x, self.y, self.x + xAxisVectorGlobalDx, self.y + xAxisVectorGlobalDy)

    love.graphics.setColor(0, 0, 255)
    yAxisVectorGlobalDx, yAxisVectorGlobalDy = geometryLib.localToGlobalVector(0, 20, self.x, self.y, self.theta)
    love.graphics.line(self.x, self.y, self.x + yAxisVectorGlobalDx, self.y + yAxisVectorGlobalDy)
  end
end

return vehicleModule
