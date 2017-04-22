--[[

= WelcomeGameState

Implements the game state interface
Connected to the RoundGameState

]]

local utils = require 'utils'
local graphicsHelpers = require 'graphicsHelpers'
local colors = require 'color'
local gameStateModule = require 'gameState'
local characterModule = require 'character'
local multiplayerGameModule = require 'multiplayerGame'

local welcomeGameStateModule = {}
local welcomeGameStateClass = {}

local GAME_STATE_ROUND_KEY = "toGameStateRound"

function welcomeGameStateModule.newWelcomeGameState(gameStateScheduler)
  utils.assertTypeTable(gameStateScheduler)

  local welcome = {}
  welcome.nextGameStates = {}
  welcome.gameStateScheduler = gameStateScheduler
  welcome.gameStateMetadata = {}

  setmetatable(welcome, {__index = welcomeGameStateClass})

  return welcome
end

function welcomeGameStateClass:schedule(metadata)
  utils.assertTypeTable(self)
  utils.assertTypeTable(metadata)
  utils.assertTypeTable(metadata.gamepads)
  self.gameStateMetadata = metadata
end

----------------------------------
-- Set the round game state
----------------------------------
function welcomeGameStateClass:addRoundGameState(roundGameState)
  gameStateModule.assertGameStateType(roundGameState)
  self.nextGameStates[GAME_STATE_ROUND_KEY] = roundGameState
end

local function switchToRoundGameState(self)
  -- when A is pressed, go to the round game state
  local metadata = self.gameStateMetadata

  -- Characters, will be available from the CharacterSelectionGameState in the future
  local gamepad1 = metadata.gamepads[1]
  local gamepad2 = metadata.gamepads[2]
  local firstCharacter = characterModule.newCharacter("Alice", colors.getColor(colors.PURPLE()), gamepad1)
  local secondCharacter = characterModule.newCharacter("Bob", colors.getColor(colors.GREEN()), gamepad2)

  -- Game
  local maxNumberOfRounds = 10
  local targetScore = 3
  local multiplayerGame = multiplayerGameModule.newGame({firstCharacter, secondCharacter}, targetScore, maxNumberOfRounds)

  -- fill the metadata
  metadata.characters = {firstCharacter, secondCharacter}
  metadata.game = multiplayerGame
  metadata.round = metadata.game:startNewRound()

  self.gameStateScheduler:schedule(self.nextGameStates[GAME_STATE_ROUND_KEY], metadata)
end

function welcomeGameStateClass:gamepadpressed(joystick, button)
  -- TODO avoid including a magic string ?
  if button == 'a' then
    switchToRoundGameState(self)
  end
end

function welcomeGameStateClass:update(dt)
  -- nothing to update
end

function welcomeGameStateClass:draw()
  graphicsHelpers.inWhite()
  graphicsHelpers.bigPrint()
  local lines = {
    "Cartarena",
    "Press 'a' to start a new game"
  }
  graphicsHelpers.printCentered(lines)
end

return welcomeGameStateModule
