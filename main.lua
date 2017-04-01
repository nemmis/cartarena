--[[

--------------------------------------------
  Cartarena
      'Slick driving and sharp shooting'
--------------------------------------------
The driving and shooting party game.

-- press 'start' to toggle debug mode
-- press 'back' to quit the game
-- press 'A' to accelerate
-- press 'B' to break
-- use the left thumbstick to steer
-- press the right bumper to shoot
]]

local colors = require 'color'
local timerModule = require 'timer'
local characterModule = require 'character'
local roundModule = require 'round'

local debuggingEnabled = false

local gamepad
local gamepad2
local firstCharacter
local secondCharacter
local map
local round
local timer

function love.load()
  -- input
  gamepad = love.joystick.getJoysticks()[1]
  gamepad2 = love.joystick.getJoysticks()[2]

  -- each player will choose his character
  firstCharacter = characterModule.newCharacter("Bob", colors.getColor(colors.PURPLE()), gamepad)
  secondCharacter = characterModule.newCharacter("Patrick", colors.getColor(colors.GREEN()), gamepad2)
  round = roundModule.newRound({firstCharacter, secondCharacter})

  -- graphics settings
  love.graphics.setLineStyle('smooth')
  love.graphics.setLineWidth(3)

  timer = timerModule.new(3000)
end


function love.update(dt)

	-- ends the game
	if gamepad:isGamepadDown('back') or gamepad2:isGamepadDown('back') or love.keyboard.isDown('escape')
		then love.event.quit()
	end

  timer:update(dt)
  round:update(dt)

end

function love.draw()

  love.graphics.setColor(colors.WHITE())
  love.graphics.print("FPS: " .. love.timer.getFPS(), 10, 10)

  -- start a new round when the round is finished
  if round:isFinished() then
    timer:start()
    love.graphics.print(string.format("Round is finished, starting new one in %0.2f seconds !", timer:getRemainingMs() / 1000), 50, 50)
    if timer:isElapsed() then
      round:destroy()
      round = roundModule.newRound({firstCharacter, secondCharacter})
      timer:stop()
      timer:reset()
    end
  else
    love.graphics.print("Round is running !", 50, 50)
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
