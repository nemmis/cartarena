--[[

= Game state interface

A game state is analogous to a screen type.
For example: Welcome Screen, GameTypeSelection screen, CharacterSelectionScreen, RoundScreen, ScoreScreen

It can be udpated and drawn.

== Interface

- void schedule(metadata), this game state becomes the current game state
- gamepadpressed(joystick, button), handle inputs
- void udpate(dt) update a game state, triggers game state changes
- void draw() draw a game state

Each implementation can link game states using specific functions
]]

local utils = require 'utils'

local gameStateModule = {}

local function isGameStateType(object)
  return utils.isTable(object)
    and utils.isFunction(object.schedule)
    and utils.isFunction(object.update)
    and utils.isFunction(object.draw)
    and utils.isFunction(object.gamepadpressed)
end

function gameStateModule.assertGameStateType(var)
  local msg = string.format("%s is not of type GameState: %s, %s, %s, %s", var, var.schedule, var.update, var.draw, var.gamepadpressed)
  assert(isGameStateType(var), msg)
end

return gameStateModule
