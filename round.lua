--[[
A round is a battle royal between 2 or more players in a given arena.

A round starts with a countdown animation and ends with a final animation.

The players can only move after the initial countdown.
]]

local roundModule = {}
local roundClass = {}

local utils = require 'utils'
local liveBulletRegistry = require 'liveBulletsRegistry'
local characterModule = require 'character'
local playerModule = require 'player'
local collisionEngineLib = require "dependencies/HC-master"
local mapModule = require 'map'
local scoreModule = require 'score'
local colorModule = require 'color'
local countdownAnimationModule = require 'countdownAnimation'
local postRoundAnimationModule = require 'postRoundAnimation'

local function registerScoreIsHitEventListenerToVehicles(score, players)
  utils.assertTypeTable(score)
  utils.assertTypeTable(players)

  for _, player in ipairs(players) do
    player:getVehicle():registerIsHitEventListener(score)
  end
end

---------------------------------------------
-- Create a new round
-- @param characters an array of characters
-- @param score the current game score
---------------------------------------------
function roundModule.newRound(characters)
  utils.assertTypeTable(characters)

  local round = {}
  round.debug = false

  round.characters = characters

  -- a round has its own collision engine instance
  round.collider = collisionEngineLib.new()

  -- create a terrain
  -- TODO in the future a terrain will be created from a Map / Arena (like Characters / Players)
  -- a terrain is local to a round, an arena is an abstract entity
  round.terrain = mapModule.newMap(round.collider)

  -- creates a local bullet registry for each round
  local bulletRegistry = liveBulletRegistry.newLiveBulletRegistry()
  round.bulletRegistry = bulletRegistry

  -- create players from characters, use starting positions of the arena
  local arenaStartingPosititions = round.terrain.getStartingPositions()
  --TODO check that there are enough starting positions

  -- Players
  round.players = {}
  for index, character in ipairs(characters) do
    local startingPosition = arenaStartingPosititions[index]
    local player = playerModule.new(
      character,
      startingPosition.x,
      startingPosition.y,
      startingPosition.theta,
      bulletRegistry,
      round.collider)
    table.insert(round.players, player)
  end

  -- Score
  round.score = scoreModule.newScore(characters)
  registerScoreIsHitEventListenerToVehicles(round.score, round.players)

  -- Pre-round animation: countdown
  round.countdownAnimation = countdownAnimationModule.newCountdownAnimation()
  round.countdownAnimation:start()

  -- Post-round animation
  round.postRoundAnimation = postRoundAnimationModule.newPostRoundAnimation()

  setmetatable(round, {__index = roundClass})

  return round
end

-- TODO destroy a round ? will it automatically be done using garbage collection ?
function roundClass:destroy()
  self.collider:resetHash()
  -- TODO need to clear the shapes of the vehicles and bullets ?
end

------------------------------------------
-- Indicates that a round is finished
-- A round is finished when there is one or zero player still alive
------------------------------------------
local function getNumberOfRemainingPlayers(round)
  local players = round.players
  local remainingPlayersCount = 0
  for i, player in ipairs(players) do
    if not player:hasLost() then
      remainingPlayersCount = remainingPlayersCount + 1
    end
  end
  return remainingPlayersCount
end

------------------------------------------
-- Indicates that a round is finished
-- A round is finished when the post round animation is finished
-- The animation is triggered when one or zero player are still alive
------------------------------------------
function roundClass:isFinished()
  return self.postRoundAnimation:isFinished()
end

function roundClass:getScore()
  return self.score
end

--------------------------------
-- Update the round
-- Round update loop
-- Update game objects in this order:
-- 1) players (vehicles)
-- 2) bullets
-- Thins to keep in mind: when a player shoots a bullet at high speed, they should not collide at the next frame if there is no other obstacles
--------------------------------
function roundClass:update(dt)
  -- pre-round animation
  self.countdownAnimation:update(dt)

  -- post round animation
  self.postRoundAnimation:update(dt)

  -- update the players, only when the countdown animation is finished
  -- TODO could disable the input and re-enable them using a callback when the animation is finished
  if self.countdownAnimation:roundCanStart() then
    for i, player in ipairs(self.players) do
      player:update(dt)
    end
  end

  -- update the bullet registry
  self.bulletRegistry:update(dt)

  -- no need to update the arena

  if getNumberOfRemainingPlayers(self) < 2 then
    self.postRoundAnimation:start()
  end

end

-----------------------------
-- Draw the round
-----------------------------
function roundClass:draw()
  self.countdownAnimation:draw()
  self.postRoundAnimation:draw()

  -- draw the arena
  self.terrain:draw()

  -- draw the players
  for i, player in ipairs(self.players) do
    player:draw()
  end

  -- update the bullet registry
  self.bulletRegistry:draw()

  self.score:draw({x = 500, y = 20}, colorModule.getColor(colorModule.ORANGE()))
end

---------------------------------
-- Enable / Disable debug mode
---------------------------------
function roundClass:setDebug(debug)
  self.debug = debug
  for i, player in ipairs(self.players) do
    player:setDebug(debug)
  end
  self.bulletRegistry:setDebug(debug)
end

function roundClass:gamepadpressed(gamepad, button)
  -- only forward input events to players when the countdown animation is finished
  if self.countdownAnimation:roundCanStart() then
    -- forward the event to all players
    for _, player in ipairs(self.players) do
      player:gamepadPressed(gamepad, button)
    end
  end
end


return roundModule
