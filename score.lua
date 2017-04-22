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
local graphicsHelpers = require 'graphicsHelpers'

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

function scoreClass:hasReachTargetScore(targetScore)
  utils.assertTypeStrictlyPositiveNumber(targetScore)
  for _, score in pairs(self) do
    if score >= targetScore then
      return true
    end
  end

  return false
end

-- @return an array of characters
function scoreClass:getLeaders()
  local leaders = {}
  local maxScore = 0
  for _, score in pairs(self:getScoreData()) do
    maxScore = math.max(score, maxScore)
  end

  for character, score in pairs(self:getScoreData()) do
    if score == maxScore then
      table.insert(leaders, character)
    end
  end

  assert(#leaders > 0, "There must be at least one leader")
  return leaders
end

-- @return {character : score}
function scoreClass:getScoreData()
  -- currently the same as the object
  return self
end

function scoreClass:draw(x, y)
  --TODO optionally set font size and color(s)
  utils.assertTypeTable(self)
  utils.assertTypeNumber(x)
  utils.assertTypeNumber(y)

  local scoreData = self:getScoreData()

  local lines = {}
  for character, score in pairs(scoreData) do
      local newLine = string.format("%s : %d points", character:getName(), score)
      table.insert(lines, newLine)
  end

  return graphicsHelpers.printLines(lines, x, y)
end

return scoreModule
