--[[
A character is the identiy of a player.
It remains the same accross a game.
It is not a game object in the sense that it is not drawn nor updated.
Its game object counterpart is the player class.

A character has:
- a name
- a visual identity (color, sprite)
- a gamepad
]]

local utils = require 'utils'
local characterModule = {}
local characterClass = {}

---------------------------------
-- Create a new character
---------------------------------
function characterModule.newCharacter(name, color, gamepad)
  utils.assertTypeString(name)
  utils.assertTypeTable(color)
  utils.assertTypeUserdata(gamepad)

  local character = {}
  character.name = name
  character.color = color
  character.gamepad = gamepad

  setmetatable(character, {__index = characterClass})

  return character
end

function characterClass:getName()
  return self.name
end

function characterClass:getColor()
  return self.color
end

function characterClass:getGamepad()
  return self.gamepad
end

return characterModule;
