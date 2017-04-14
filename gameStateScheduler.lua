--[[

= Game State scheduler

A singleton
Displays the current game state.
Handles transitions between game states.
Forward inputs to the current game state
]]

local utils = require 'utils'
local gameStateModule = require 'gameState'

local gameStateSchedulerModule = {}

local gameStateSchedulerClass = {}

----------------------------------
-- Create a game state scheduler
----------------------------------
function gameStateSchedulerModule.newGameStateScheduler()
  local scheduler = {}
  scheduler.currentGameState = nil

  setmetatable(scheduler, {__index = gameStateSchedulerClass})

  return scheduler
end

function gameStateSchedulerClass:schedule(nextGameState, gameStateMetadata)
  utils.assertTypeTable(self)
  gameStateModule.assertGameStateType(nextGameState)
  utils.assertTypeTable(gameStateMetadata)

  -- set the new current state, input will now be forwarded to this new game state
  self.currentGameState = nextGameState

  -- tell the new game state that it is now active, pass the metadata to it
  nextGameState:schedule(gameStateMetadata)
end

function gameStateSchedulerClass:gamepadpressed(joystick, button)
  self.currentGameState:gamepadpressed(joystick, button)
end

function gameStateSchedulerClass:getCurrentGameState()
  return self.currentGameState
end

return gameStateSchedulerModule
