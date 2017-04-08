--[[

= Score

Keeps track of the score for a set of characters.
It is an IsHitEventListener: listens for IsHitEvents that are fired by vehicles.

== Score update

A hit increases the score by one.
An own kill decreases the score by one. Hence, the score of a character can be negative.
This way, a player cannot simply hit himself if only two players remain and one has an edge on the other, e.g many more bullets.

]]

local utils = require 'utils'
local colors = require 'color'

local scoreModule = {}
local scoreClass = {}

----------------------------------------------
-- Creates a new score
----------------------------------------------
function scoreModule.newScore(characters)
  utils.assertTypeTable(characters)
  assert(#characters >= 2 and #characters <= 4, "A score has to be created with two players minimum and four players maximum")

  local score = {}

  for _, character in ipairs(characters) do
    score[character] = 0
  end

  setmetatable(score, {__index = scoreClass})

  return score
end

----------------------------------------------
-- process an IsHitEvent
----------------------------------------------
function scoreClass:processIsHitEvent(isHitEvent)
  utils.assertTypeTable(self)
  utils.assertTypeTable(isHitEvent)

  local target = isHitEvent:getTarget()
  local shooter = isHitEvent:getShooter()

  assert(self[target], "The target character is not tracked by the score")
  assert(self[shooter], "The shooter character is not tracked by the score")

  if(target ~= shooter) then
    self[shooter] = self[shooter] + 1
  else -- character shot itself
    self[target] = self[target] - 1
  end
end

-----------------------------------------
-- Add a score to an existing score
-----------------------------------------
function scoreClass:add(otherScore)
  utils.assertTypeTable(otherScore)
  -- TODO assert that the two scores are compatible, ie they have the same characters

  for otherCharacter, otherScore in pairs(otherScore) do
    self[otherCharacter] = self[otherCharacter] + otherScore
  end

end

function scoreClass:draw(offset, color)
  utils.assertTypeTable(color)

  local offset = offset or {x = 0, y = 0}

  love.graphics.setColor(colors.getRGB(color))

  local i = 0
  for character, score in pairs(self) do
    love.graphics.print(string.format('%s : %d', character:getName(), score), offset.x, offset.y + i * 10)
    i = i + 1
  end
end

return scoreModule
