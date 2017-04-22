--[[
A multiplayer game

It knows:
- the characters
- the target score

A game run consists of a series of rounds.
A game is finished when a player reaches the target score or the maximum number of rounds is reached.
A maximum number of round is needed to be sure a game terminates (negative scores are currently possible).

0 several player can win the game at the same time, what in case of tie breaks ?
  - there are two winners
  - could take the player that has the most victory against its opponent
  - could have a last round with the player that have the same score, latest battle royal that decides on the winner
]]

local utils = require 'utils'
local roundModule = require 'round'
local scoreModule = require 'score'

local gameModule = {}

local gameClass = {}

local MIN_NUMBER_PLAYERS = 2
local MAX_NUMBER_PLAYERS = 4

-----------------------------------
-- Creates a new multiplayer game
-----------------------------------
function gameModule.newGame(characters, targetScore, maxNumberOfRounds)
  utils.assertTypeTable(characters)
  assert(#characters >= MIN_NUMBER_PLAYERS, string.format("A game must have at least %s players", MIN_NUMBER_PLAYERS))
  assert(#characters <= MAX_NUMBER_PLAYERS, string.format("A game must have at most %s players", MAX_NUMBER_PLAYERS))

  utils.assertTypeStrictlyPositiveNumber(targetScore)
  utils.assertTypeStrictlyPositiveNumber(maxNumberOfRounds)

  local game = {}
  game.characters = characters
  game.numberOfRounds = 0
  game.maxNumberOfRounds = maxNumberOfRounds
  game.score = scoreModule.newScore(characters)
  game.targetScore = targetScore

  setmetatable(game, {__index = gameClass})
  return game
end

function gameClass:updateGameScore(roundScore)
  utils.assertTypeTable(roundScore)
  self.score:add(roundScore)
end

---------------------------------
-- A game is finished if
-- - the target score is reached by at least one player
-- - the maximum number of rounds is reached
---------------------------------
function gameClass:isFinished()
  local maxNumberOfRoundsReached = self.numberOfRounds >= self.maxNumberOfRounds
  local targetScoreReached = self.score:hasReachTargetScore(self.targetScore)

  return targetScoreReached or maxNumberOfRoundsReached
end

-- return a new round and increment number of round by one
function gameClass:startNewRound()
  self.numberOfRounds = self.numberOfRounds + 1
  return roundModule.newRound(self.characters)
end

function gameClass:getScore()
  return self.score
end

function gameClass:getTargetScore()
  return self.targetScore
end

function gameClass:getRoundCount()
  return self.numberOfRounds
end

function gameClass:getMaxRoundCount()
  return self.maxNumberOfRounds
end



return gameModule
