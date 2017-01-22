-- press start to toggle global debug mode
-- press Y to drive in 3rd person model
-- press X to drive in 1st person mode

local map = require "map"
local colors = require "color"
local vehicleInput = require "vehicleInput"
local vehicle = require "vehicle/vehicle"

local debuggingEnabled = true
local drivingInputType = vehicleInput.TYPE_THIRD_PERSON()

local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

local vehicle = vehicle.new(WIDTH / 16, HEIGHT / 2, 0, debuggingEnabled)
local gamepad = nil

function love.load()
  gamepad = love.joystick.getJoysticks()[1]
end

function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

  -- driving inputs
  local accelerates, breaks, steers = vehicleInput.getDriverInput(gamepad, vehicle, drivingInputType)

  vehicle:update(dt, accelerates, breaks, steers)

end

function love.draw()

  love.graphics.setColor(colors.WHITE())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)

  --draw map
  map.drawMap()
  vehicle:draw()

  if debuggingEnabled
      then
      -- driving mode
      love.graphics.setColor(colors.WHITE())
      love.graphics.print(string.format("Driving type: %s", drivingInputType), 5, 20)
  end
end

function love.gamepadpressed( joystick, button )
  -- toggle debug drawing
  if button == 'start'
  then debuggingEnabled = not debuggingEnabled
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
