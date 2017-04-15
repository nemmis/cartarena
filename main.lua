--[[

--------------------------------------------
  Cartarena
      'Slick driving and sharp shooting'
--------------------------------------------
The driving and shooting party game.

A game is a serie of battle royal.

-- press 'start' to toggle debug mode
-- press 'back' to quit the game
-- press 'A' to accelerate
-- press 'B' to break
-- use the left thumbstick to steer
-- press the right bumper to shoot
]]

local graphicsHelpers = require 'graphicsHelpers'
local gameStateSchedulerModule = require 'gameStateScheduler'
local welcomeGameStateModule = require 'welcomeGameState'
local roundGameStateModule = require 'roundGameState'
local scoreGameStateModule = require 'scoreGameState'

local debuggingEnabled = false

local gameStateMetadata
local gameStateScheduler

local maxMemoryUsage = 0

function love.load()

  -- log version information
  local major, minor, revision, codename = love.getVersion()
  print(string.format("Love2d version: %d.%d.%d - %s", major, minor, revision, codename))
  print(string.format("lua version: %s",_VERSION))

  -- game state scheduler
  gameStateScheduler = gameStateSchedulerModule.newGameStateScheduler()

  -- game state metadata
  gameStateMetadata = {}
  gameStateMetadata.gamepads = {love.joystick.getJoysticks()[1], love.joystick.getJoysticks()[2]}

  -- create the game state graph nodes
  local welcomeGameState = welcomeGameStateModule.newWelcomeGameState(gameStateScheduler)
  local roundGameState = roundGameStateModule.newRoundGameState(gameStateScheduler)
  local scoreGameState = scoreGameStateModule.newScoreGameState(gameStateScheduler)

  -- wire the game states nodes
  welcomeGameState:addRoundGameState(roundGameState)
  roundGameState:addScoreGameState(scoreGameState)
  scoreGameState:addRoundGameState(roundGameState)
  scoreGameState:addWelcomeGameState(welcomeGameState)

  -- start the game
  gameStateScheduler:schedule(welcomeGameState, gameStateMetadata)

  -- graphics settings
  love.graphics.setLineStyle('smooth')
  love.graphics.setLineWidth(3)
end


function love.update(dt)

	-- ends the game
	if love.keyboard.isDown('escape')
		then love.event.quit()
	end

  gameStateScheduler:getCurrentGameState():update(dt)

end

local function drawPerformanceData()
  graphicsHelpers.smallPrint()
  graphicsHelpers.inWhite()
  maxMemoryUsage = math.max(maxMemoryUsage, collectgarbage("count"))
  local lines = {
    string.format("FPS (f/sec): %d", love.timer.getFPS()),
    string.format("Mem (Kb): max %d current %d", maxMemoryUsage, collectgarbage("count"))
  }
  graphicsHelpers.printLines(lines, 15, 15)
end

function love.draw()
  drawPerformanceData()
  gameStateScheduler:getCurrentGameState():draw()
end

function love.gamepadpressed(joystick, button)
  gameStateScheduler:gamepadpressed(joystick, button)
end
