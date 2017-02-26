-- press start to toggle global debug mode
-- press Y to drive in 3rd person model
-- press X to drive in 1st person mode

local mapModule = require "map"
local colors = require "color"
local vehicleInput = require "vehicleInput"
local vehicleModule = require "vehicle/vehicle"
local trajectoryModule = require "trajectory"
local bulletModule = require "bullet"
local playerModule = require "player"

-- creates a Collision Detection Module instance
local HC = require "dependencies/vrld-HC-410cf04"

local debuggingEnabled = true
local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

-- player can be gamepad + vehicle + trajectory
local player1
local player2

local drivingInputType = vehicleInput.TYPE_THIRD_PERSON()
local gamepad
local gamepad2
local map
local bullet

local rectangleObstacle

function love.load()
  -- input
  gamepad = love.joystick.getJoysticks()[1]
  gamepad2 = love.joystick.getJoysticks()[2]

  -- map
  mapModule.init(HC)
  vehicleModule.init(HC)
  bulletModule.init(HC)

  -- players
  player1 = playerModule.new(WIDTH / 16, HEIGHT / 8, gamepad, debuggingEnabled)
  player2 = playerModule.new(4 * WIDTH / 16, HEIGHT / 8, gamepad2, debuggingEnabled)

  -- bullet
  bullet = bulletModule.newPickedBullet(debuggingEnabled)
end

function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

  bullet:update(dt)

  -- first player
  if gamepad then
    player1:update(dt)
  end

  -- second player
  if gamepad2 then
    player2:update(dt)
  end

end

function love.draw()

  love.graphics.setColor(colors.WHITE())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)

  mapModule.draw()
  player1:draw()
  player2:draw()
  bullet:draw()

  if debuggingEnabled
      then
      -- driving mode
      love.graphics.setColor(colors.WHITE())
      love.graphics.print(string.format("Driving type: %s", drivingInputType), 5, 20)
  end
end

function love.gamepadpressed( joystick, button )
  -- any gamepad

  -- toggle debug drawing
  if button == 'start'
  then debuggingEnabled = not debuggingEnabled
      player1:setDebug(debuggingEnabled)
      player2:setDebug(debuggingEnabled)
      bullet:setDebug(debuggingEnabled)
  end

  if button == 'y'
  then drivingInputType = vehicleInput.TYPE_THIRD_PERSON()
  end

  if button == 'x'
  then drivingInputType = vehicleInput.TYPE_FIRST_PERSON()
  end

  if button == 'rightshoulder' then
    bullet:fire(player1.vehicle.x, player1.vehicle.y, -1, 1)
  end

  if button == 'leftshoulder' then
    bullet:pickUp()
  end


end

function love.keypressed( key, scancode, isrepeat )
	print("Key" .. key .. " has just been pressed")
end
