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
local scoreModule = require 'score'

local debuggingEnabled = false

local gamepad
local gamepad2
local firstCharacter
local secondCharacter
local map
local round
local timer
local gameScore

function love.load()
  -- input
  gamepad = love.joystick.getJoysticks()[1]
  gamepad2 = love.joystick.getJoysticks()[2]


  -- Characters
  -- each player will choose his character
  firstCharacter = characterModule.newCharacter("Bob", colors.getColor(colors.PURPLE()), gamepad)
  secondCharacter = characterModule.newCharacter("Patrick", colors.getColor(colors.GREEN()), gamepad2)

  -- Round
  round = roundModule.newRound({firstCharacter, secondCharacter})

  -- Game score
  gameScore = scoreModule.newScore({firstCharacter, secondCharacter})

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
      -- start a new round

      gameScore:add(round:getScore()) -- merge the score
      round:destroy() -- destroy the round
      round = roundModule.newRound({firstCharacter, secondCharacter}) -- create a new round
      timer:stop()
      timer:reset()
    end
  else
    love.graphics.print("Round is running !", 50, 50)
  end

  round:draw()

  gameScore:draw({ x = 400, y = 20}, colors.getColor(colors.GREEN()))

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
