--[[

= Score game state

Display the score of the game.
Goes to the round game state if the game is not finished
Goes to the welcomeState if the game is finished
In the future will also be linked to the pause game state
Makes use of the field 'game' in the metadata

]]

local utils = require 'utils'
local graphicsHelpers = require 'graphicsHelpers'
local colors = require 'color'
local gameStateModule = require 'gameState'
local roundModule = require 'round'
local gameStateSchedulerModule = require 'gameStateScheduler'

local scoreGameStateModule = {}

local scoreGameStateClass = {}

local GAME_STATE_ROUND_KEY = 'toRoundGameState'
local GAME_STATE_WELCOME_KEY = 'toWelcomeGameState'

function scoreGameStateModule.newScoreGameState(gameStateScheduler)

  local scoreGameState = {}
  scoreGameState.gameStateScheduler = gameStateScheduler
  scoreGameState.gameStateMetadata = nil
  scoreGameState.nextGameStates = {}

  setmetatable(scoreGameState, {__index = scoreGameStateClass})

  return scoreGameState
end

function scoreGameStateClass:addRoundGameState(roundGameState)
  gameStateModule.assertGameStateType(roundGameState)
  self.nextGameStates[GAME_STATE_ROUND_KEY] = roundGameState
end

function scoreGameStateClass:addWelcomeGameState(welcomeGameState)
  gameStateModule.assertGameStateType(welcomeGameState)
  self.nextGameStates[GAME_STATE_WELCOME_KEY] = welcomeGameState
end

-- TODO move this function to the GameState interface
-- enter in the score game state
-- we come from the round game state, the round game state needs to give the score of the round
-- do not update the score of the game here !, this state might be scheduled from the PauseGameState
function scoreGameStateClass:schedule(metadata)
  utils.assertTypeTable(metadata)
  utils.assertTypeTable(metadata.game)

  self.gameStateMetadata = metadata
end

local function switchToRoundGameState(self)
  -- the game is not finished, create a new round, this will increase the number of rounds
  self.gameStateMetadata.round = self.gameStateMetadata.game:startNewRound()
  self.gameStateScheduler:schedule(self.nextGameStates[GAME_STATE_ROUND_KEY], self.gameStateMetadata)
end

local function switchToWelcomeGameState(self)
  -- the game is finished, set the game metadata to nil
  -- no information to send
  self.gameStateMetadata.game = nil
  self.gameStateScheduler:schedule(self.nextGameStates[GAME_STATE_WELCOME_KEY], self.gameStateMetadata)
end

function scoreGameStateClass:gamepadpressed(joystick, button)
  if button == 'a' then
    if self.gameStateMetadata.game:isFinished() then
      switchToWelcomeGameState(self)
    else
      switchToRoundGameState(self)
    end
  end
end

function scoreGameStateClass:update(dt)
  -- nothing to update
end

local function drawWinningCase(score, x, y)
--TODO differentiate when the maximum number of rounds is reached or the target score is reached ?

  local leaders = score:getLeaders()

  if #leaders > 1 then
    y = y + graphicsHelpers.printLines({"It's a draw !"}, x, y)
  end

  local winnerString = ""
  for _, leader in ipairs(leaders) do
    winnerString = winnerString .. string.format("%s, ", leader:getName())
  end

  winnerString = winnerString .. "wins !"

  y = y + graphicsHelpers.printLines({winnerString}, x, y)
  y = y + graphicsHelpers.printLines({"Press 'a' to come back to the welcome screen"}, x, y)
end


function scoreGameStateClass:draw()
  graphicsHelpers.smallPrint()
  local game = self.gameStateMetadata.game
  local score = game:getScore()

  local x = 200
  local y = 200
  local lines = {
    string.format("Multiplayer game (%d / %d rounds)", game:getRoundCount(), game:getMaxRoundCount()),
    string.format("First to %d ! ", game:getTargetScore())
  }
  y = y + graphicsHelpers.printLines(lines, x, y)
  y = y + score:draw(x, y)

  if not game:isFinished() then
    graphicsHelpers.printLines({"No winner yet, press 'a' to continue to the next round"}, x, y)
  else
    drawWinningCase(score, x, y)
  end

end

return scoreGameStateModule
