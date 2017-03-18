--[[
A character is the identiy of a player.
It remains the same accross a game.
]]

local utils = require 'utils'
local characterModule = {}
local characterClass = {}

function characterModule.newCharacter(name, color, gamepad)
  assert(name, "The character must have a name")
  utils.assertTypeString(name)
  assert(color, "The character must have a color")
  utils.assertTypeTable(color)
  assert(gamepad, "The character must have a gamepad")

  local character = {}
  character.name = name
  character.color = color
  character.gamepad = gamepad

  setmetatable(character, {__index = characterClass})

  return character
end

return characterModule;
