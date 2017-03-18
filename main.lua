-- Main game
-- press start to toggle debug mode
-- press Y to drive in 3rd person model
-- press X to drive in 1st person mode
-- press 'back' to quit the game


local colors = require 'color'
local characterModule = require 'character'
local mapModule = require 'map'
local roundModule = require 'round'
local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'
local bulletModule = require 'bullet'

-- creates a Collision Detection Module instance
local HC = require "dependencies/vrld-HC-410cf04"

local debuggingEnabled = false
local drivingInputType = vehicleInput.TYPE_THIRD_PERSON()

local gamepad
local gamepad2
local firstCharacter
local secondCharacter
local round

function love.load()
  -- input
  gamepad = love.joystick.getJoysticks()[1]
  gamepad2 = love.joystick.getJoysticks()[2]

  -- module initialization
  mapModule.init(HC)
  vehicleModule.init(HC)
  bulletModule.init(HC)

  -- creates the characters
  -- each player will choose his characters
  firstCharacter = characterModule.newCharacter("Bob", colors.getColor(colors.PURPLE()), gamepad)
  secondCharacter = characterModule.newCharacter("Patrick", colors.getColor(colors.GREEN()), gamepad2)

  -- creates a round
  -- TODO do not pass the map module but an instance of a map
  round = roundModule.newRound({firstCharacter, secondCharacter}, mapModule)

end


function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

  round:update(dt)

end

function love.draw()

  love.graphics.setColor(colors.WHITE())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 5, 5)

  if round:isFinished() then
    love.graphics.print("Round is finished !", 50, 50)
  end

  round:draw()

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
      round:setDebug(debuggingEnabled)
  end

  if button == 'y'
    then drivingInputType = vehicleInput.TYPE_THIRD_PERSON()
  end

  if button == 'x'
    then drivingInputType = vehicleInput.TYPE_FIRST_PERSON()
  end

  round:gamepadPressed(joystick, button)
end

function love.keypressed( key, scancode, isrepeat )
	print("Key" .. key .. " has just been pressed")
end
