-- enable global debug mode with start
-- press Y to drive in 3rd person model
-- press X to drive in 1st person mode

local geometryLib = require "geometryLib"
local map = require "map"
local colors = require "color"
local vehicleInput = require "vehicleInput"

globalDebugFlag = true
drivingInputType = vehicleInput.TYPE_THIRD_PERSON()

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

local player = {x = WIDTH / 16, y = HEIGHT / 2, theta = 0, vx = 0, vy = 0}
local PLAYER_ACCELERATION = 800 -- Px sec-2
local PLAYER_BREAK = 800
local PLAYER_MAX_SPEED = 350 -- Px sec-1
local PLAYER_FRICTION = -3 -- Px sec-1
local PLAYER_ROTATION_SPEED = 3 -- rad sec-1

local gamepad = nil
local thumbstickSensitivity = 0.15 -- thumbstick considered at rest if value in [-thumbstickSensitivity thumbstickSensitivity]

-- -- Find which direction keys are pressed: return a set of booleans
-- local function getDirectionKeys()
--
--     local right = false
--     local left = false
--     local up = false
--     local down = false
--
--     if gamepad:isGamepadDown('dpright')
--     then right = true
--     end
--
--     if gamepad:isGamepadDown('dpleft')
--     then left = true
--     end
--
--     if gamepad:isGamepadDown('a')
--     then up = true
--     end
--
--     if gamepad:isGamepadDown('b')
--     then down = true
--     end
--
--     return right, left, up, down
-- end

function love.load()
  gamepad = love.joystick.getJoysticks()[1]
end

function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

	-- inputs for acceleration and rotation
	-- local right, left, up, down = getDirectionKeys()

  -- new input model
  local up, down, rotationFactor = vehicleInput.getDriverInput(gamepad, player, drivingInputType)
  --print("Rotation factor: " .. rotationFactor)

	local accelerationFactor = 0

	if up > 0
		then accelerationFactor = 1 * PLAYER_ACCELERATION
	elseif down > 0
		then accelerationFactor = -1 * PLAYER_BREAK
	end

  -- local rotationFactor = 0
	-- if right
	-- 	then rotationFactor = 1
	-- 	elseif left
	-- 		then rotationFactor = -1
	-- 	end

  -- only change for the first implementation of the controls
  -- rotationFactor = gamepad:getGamepadAxis("leftx")
  -- if math.abs(rotationFactor) < thumbstickSensitivity
  -- then rotationFactor = 0
  -- end



-- find the norm of the speed
-- speed norm bounded between 0 and PLAYER_MAX_SPEED
-- the speed is always in the direction of the local Y axis at the start of an update loop
	local x1 = player.x
	local y1 = player.y
	local v1x = player.vx
	local v1y = player.vy
	local theta1 = player.theta
	local v1Norm = geometryLib.getNorm(v1x, v1y)

	local newSpeedNorm = v1Norm + accelerationFactor * dt + PLAYER_FRICTION
	if newSpeedNorm > PLAYER_MAX_SPEED
		then newSpeedNorm = PLAYER_MAX_SPEED
	elseif newSpeedNorm < 0
		then newSpeedNorm = 0
	end

	-- find the speed, potentially rotated
	-- for floating point values
	-- could simplify the code by introducing a speed direction, we have the formula if old speed is not null vector, if vehicle is stopped then it is the Y axis of the local coordinate system
	local newSpeedDirXNormalized, newSpeedDirYNormalized = geometryLib.localToGlobalVector(0, 1, x1, y1, theta1)
	local thetaDelta = 0
	if newSpeedNorm > 0	and rotationFactor ~= 0 -- if the speed norm is null, the speed is the null vector
		then
							thetaDelta = rotationFactor * PLAYER_ROTATION_SPEED * dt
							newSpeedDirXNormalized, newSpeedDirYNormalized = geometryLib.rotate(newSpeedDirXNormalized, newSpeedDirYNormalized, thetaDelta)
	end

	-- newSpeed norm might be null
	newSpeedX = newSpeedNorm * newSpeedDirXNormalized
	newSpeedY = newSpeedNorm * newSpeedDirYNormalized

	local newPositionX = x1 + newSpeedX * dt
	local newPositionY = y1 + newSpeedY * dt

	-- if newSpeedNorm > 0
	-- 	then
	-- 		print(thetaDelta)
	-- 		print(newSpeedX)
	-- 		print(newSpeedY)
	-- 		print(newSpeedNorm .. " " .. newPositionX .. " " .. newPositionY)
	-- end

	-- update the player
	player.x = newPositionX
	player.y = newPositionY
	player.vx = newSpeedX
	player.vy = newSpeedY
	player.theta = player.theta + thetaDelta

end

function love.draw()
  -- draw player
  love.graphics.setColor(colors.ORANGE())

  -- line for the player in Px
  -- be careful player.x, player.y should be the center of gravity
  local ax, ay = geometryLib.localToGlobalPoint(0, 20, player.x, player.y, player.theta)
  local bx, by = geometryLib.localToGlobalPoint(10, -10, player.x, player.y, player.theta)
  local cx, cy = geometryLib.localToGlobalPoint(-10, -10, player.x, player.y, player.theta)
  love.graphics.line(ax, ay, bx, by, cx, cy, ax, ay)

  --draw map
  map.drawMap()

  love.graphics.setColor(colors.BLACK())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

    if globalDebugFlag
        then
        -- driving mode
        love.graphics.setColor(colors.WHITE())
        love.graphics.print(string.format("Driving type: %s", drivingInputType), 5, 5)

        -- player position
        love.graphics.setColor(colors.WHITE())
        love.graphics.circle("line", player.x, player.y, 5)

        -- display speed in green
        love.graphics.setColor(0, 255, 0)
        love.graphics.line(player.x, player.y, player.x + player.vx, player.y + player.vy)

				-- coordinates system
				love.graphics.setColor(255, 0, 0)
				xAxisVectorGlobalDx, xAxisVectorGlobalDy = geometryLib.localToGlobalVector(20, 0, player.x, player.y, player.theta)
				love.graphics.line(player.x, player.y, player.x + xAxisVectorGlobalDx, player.y + xAxisVectorGlobalDy)

				love.graphics.setColor(0, 0, 255)
				yAxisVectorGlobalDx, yAxisVectorGlobalDy = geometryLib.localToGlobalVector(0, 20, player.x, player.y, player.theta)
				love.graphics.line(player.x, player.y, player.x + yAxisVectorGlobalDx, player.y + yAxisVectorGlobalDy)
    end
end

function love.gamepadpressed( joystick, button )
  -- toggle debug drawing
  if button == 'start'
  then globalDebugFlag = not globalDebugFlag
  end

  if button == 'y'
  then drivingInputType = vehicleInput.TYPE_THIRD_PERSON()
  end

  if button == 'x'
  then drivingInputType = vehicleInput.TYPE_FIRST_PERSON()
  end

end

function love.keypressed( key, scancode, isrepeat )
	print("Key" .. key .. " has just been pressed")
end
