--[[
A round is a battle royal between 2 or more players in a given arena.

]]

local roundModule = {}
local roundClass = {}

local utils = require 'utils'
local liveBulletRegistry = require 'liveBulletsRegistry'
local characterModule = require 'character'
local playerModule = require 'player'
local collisionEngineLib = require "dependencies/HC-master"
local mapModule = require 'map'

---------------------------------------------
-- Create a new round
-- @param characters an array of characters
-- @param the arena
---------------------------------------------
function roundModule.newRound(characters)
  utils.assertTypeTable(characters)

  local round = {}
  round.characters = characters
  round.debug = false

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

  round.players = {}
  for index, character in ipairs(characters) do
    local startingPosition = arenaStartingPosititions[index]
    local player = playerModule.new(
      startingPosition.x,
      startingPosition.y,
      startingPosition.theta,
      bulletRegistry,
      character.color,
      character.gamepad,
      round.collider)
    table.insert(round.players, player)
  end

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
-- A round is finished when all players
------------------------------------------
function roundClass:isFinished()
  local players = self.players
  local remainingPlayersCount = 0
  for i, player in ipairs(players) do
    if not player:hasLost() then
      remainingPlayersCount = remainingPlayersCount + 1
    end
  end
  -- all the player might have already lost (two remaining players might loose during the same update frame)
  return remainingPlayersCount < 2
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
  -- update the players
  for i, player in ipairs(self.players) do
    player:update(dt)
  end

  -- update the bullet registry
  self.bulletRegistry:update(dt)

  -- no need to update the arena
end

-----------------------------
-- Draw the round
-----------------------------
function roundClass:draw()
  -- draw the arena
  self.terrain:draw()

  -- draw the players
  for i, player in ipairs(self.players) do
    player:draw()
  end

  -- update the bullet registry
  self.bulletRegistry:draw()
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

function roundClass:gamepadPressed(gamepad, button)
  -- forward the event to all players
  for _, player in ipairs(self.players) do
    player:gamepadPressed(gamepad, button)
  end
end


return roundModule
