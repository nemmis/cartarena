-- press start to toggle global debug mode
-- press Y to drive in 3rd person model
-- press X to drive in 1st person mode

local mapModule = require "map"
local colors = require "color"
local vehicleInput = require "vehicleInput"
local vehicleModule = require "vehicle/vehicle"
local trajectoryModule = require "trajectory"
local bulletModule = require "bullet"

-- creates a Collision Detection Module instance
local HC = require "dependencies/vrld-HC-410cf04"

local debuggingEnabled = true
local HEIGHT = love.graphics.getHeight()
local WIDTH = love.graphics.getWidth()

-- player can be gamepad + vehicle + trajectory
local drivingInputType = vehicleInput.TYPE_THIRD_PERSON()
local gamepad
local gamepad2
local vehicle
local vehicle2
local map
local trajectory
local trajectory2
local bullet
local trajectoryBullet

local rectangleObstacle

function love.load()
  -- input
  gamepad = love.joystick.getJoysticks()[1]
  gamepad2 = love.joystick.getJoysticks()[2]

  -- map
  mapModule.init(HC)

  -- vehicles
  vehicleModule.init(HC)
  vehicle = vehicleModule.new(WIDTH / 16, HEIGHT / 8, 0, debuggingEnabled)
  vehicle2 = vehicleModule.new(4 * WIDTH / 16, HEIGHT / 8, 0, debuggingEnabled)

  -- trajectories
  trajectory = trajectoryModule.new()
  trajectory2 = trajectoryModule.new()
  trajectoryBullet = trajectoryModule.new()

  -- bullet
  bulletModule.init(HC)
  bullet = bulletModule.new(300, 700, 1, -1)
end

function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

  bullet:update(dt)
  trajectoryBullet:add(bullet.x, bullet.y)

  -- first player
  if gamepad then
    local accelerates, breaks, steers = vehicleInput.getDriverInput(gamepad, vehicle, drivingInputType)
    vehicle:update(dt, accelerates, breaks, steers)
    trajectory:add(vehicle.x, vehicle.y)
  end

  -- second player
  if gamepad2 then
    local accelerates, breaks, steers = vehicleInput.getDriverInput(gamepad2, vehicle2, drivingInputType)
    vehicle2:update(dt, accelerates, breaks, steers)
    trajectory2:add(vehicle2.x, vehicle2.y)
  end


end

function love.draw()

  love.graphics.setColor(colors.WHITE())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)


  mapModule.draw()

  vehicle:draw()


  vehicle2:draw()


  bullet:draw()


  if debuggingEnabled
      then
      -- driving mode
      love.graphics.setColor(colors.WHITE())
      love.graphics.print(string.format("Driving type: %s", drivingInputType), 5, 20)

      trajectory:draw()
      trajectoryBullet:draw()
      trajectory2:draw()
  end
end

function love.gamepadpressed( joystick, button )
  -- any gamepad

  -- toggle debug drawing
  if button == 'start'
  then debuggingEnabled = not debuggingEnabled
    vehicle:setDebug(debuggingEnabled)
    vehicle2:setDebug(debuggingEnabled)
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
