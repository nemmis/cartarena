--[[

= Round Game State

Can be reached from / When:
- welcomeGameState
- scoreGameState
- (PauseGameState)

Needs the metadata field(s):
- round

Can switch to / When :
- scoreGameState when the round is finished
- (PauseGameState when pause is requested by any players)

Provides the metadata field(s):
- update the score of the game
- set the round metadata field to nil

]]

local utils = require 'utils'
local gameStateModule = require 'gameState'

local roundGameStateModule = {}

local roundGameStateClass = {}

function roundGameStateModule.newRoundGameState(gameStateScheduler)
  local roundGameState = {}
  roundGameState.gameStateScheduler = gameStateScheduler
  roundGameState.gameStateMetadata = {}
  roundGameState.nextGameStates = {}
  setmetatable(roundGameState, {__index = roundGameStateClass})
  return roundGameState
end

function roundGameStateClass:schedule(metadata)
  utils.assertTypeTable(self)
  utils.assertTypeTable(metadata)
  utils.assertTypeTable(metadata.round)
  self.gameStateMetadata = metadata
end

---------------------------------------------------------------
-- Add next game states and local functions to switch to them
---------------------------------------------------------------
local GAME_STATE_SCORE_KEY = 'toGameStateScore'

function roundGameStateClass:addScoreGameState(scoreGameState)
  gameStateModule.assertGameStateType(scoreGameState)
  self.nextGameStates[GAME_STATE_SCORE_KEY] = scoreGameState
end

local function switchToScoreGameState(self)
  utils.assertTypeTable(self)
  -- set the score on the metadata
  self.gameStateMetadata.game:updateGameScore(self.gameStateMetadata.round:getScore())

  -- destroy the round
  self.gameStateMetadata.round:destroy()
  self.gameStateMetadata.round = nil

  self.gameStateScheduler:schedule(self.nextGameStates[GAME_STATE_SCORE_KEY], self.gameStateMetadata)
end

function roundGameStateClass:gamepadpressed(joystick, button)
  local round = self.gameStateMetadata.round

  -- enable the debug mode when start is pressed on any controller
  if button == 'start' then
    round:setDebug(not round:getDebug())
  end
  
  -- forward input to the running round
  round:gamepadpressed(joystick, button)
end

function roundGameStateClass:update(dt)
  self.gameStateMetadata.round:update(dt)
  if self.gameStateMetadata.round:isFinished() then
    switchToScoreGameState(self)
  end
end

function roundGameStateClass:draw()
  self.gameStateMetadata.round:draw()
end

return roundGameStateModule
