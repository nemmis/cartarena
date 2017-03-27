-- Main game
-- press start to toggle debug mode
-- press 'back' to quit the game

local colors = require 'color'
local characterModule = require 'character'
local mapModule = require 'map'
local roundModule = require 'round'
local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'
local bulletModule = require 'bullet'

-- creates a Collision Detection Module instance
local HC = require "dependencies/HC-master"

local debuggingEnabled = false

local gamepad
local gamepad2
local firstCharacter
local secondCharacter
local map
local round

function love.load()
  -- input
  gamepad = love.joystick.getJoysticks()[1]
  gamepad2 = love.joystick.getJoysticks()[2]

  -- module initialization
  mapModule.init(HC)
  vehicleModule.init(HC)
  bulletModule.init(HC)

  -- each player will choose his character
  firstCharacter = characterModule.newCharacter("Bob", colors.getColor(colors.PURPLE()), gamepad)
  secondCharacter = characterModule.newCharacter("Patrick", colors.getColor(colors.GREEN()), gamepad2)

  map = mapModule.newMap()

  round = roundModule.newRound({firstCharacter, secondCharacter}, map)

  -- graphics settings
  love.graphics.setLineStyle('smooth')
  love.graphics.setLineWidth(1)

end


function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or gamepad2:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

  round:update(dt)

end

function love.draw()

  love.graphics.setColor(colors.WHITE())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

  if round:isFinished() then
    love.graphics.print("Round is finished !", 50, 50)
  end

  round:draw()

end

function love.gamepadpressed( joystick, button )
  -- any gamepad

  -- toggle debug drawing
  if button == 'start'
  then debuggingEnabled = not debuggingEnabled
      round:setDebug(debuggingEnabled)
  end

  round:gamepadPressed(joystick, button)
end

function love.keypressed( key, scancode, isrepeat )
	print("Key" .. key .. " has just been pressed")
end
