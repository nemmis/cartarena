--[[

= Coutdown animation

Used before starting a round
3..2..1.. Go !

]]
local timerModule = require 'timer'
local graphicsHelpers = require 'graphicsHelpers'

local countdownAnimationModule = {}

local countdownAnimationClass = {}

function countdownAnimationModule.newCountdownAnimation()
  local anim = {}

  anim.scalingFactor = 0.8
  anim.countdownTimer = timerModule.new(3000 * anim.scalingFactor) -- 3 seconds count down
  anim.goTimer = timerModule.new(1000) -- display "Go" for 1 second

  setmetatable(anim, {__index = countdownAnimationClass})

  return anim
end

function countdownAnimationClass:update(dt)
  self.countdownTimer:update(dt)
  if self.countdownTimer:isElapsed() then
    self.goTimer:start()
  end
  self.goTimer:update(dt)
end

-- only draw an animation when it is running
function countdownAnimationClass:draw()
  graphicsHelpers.bigPrint()
  local msg = ""
  if self.countdownTimer:isRunning() then
    msg = string.format("%d", math.ceil(self.countdownTimer:getRemainingMs() * (1 / self.scalingFactor) / 1000))
  elseif self.goTimer:isRunning() then
    msg = "Go !"
  end
  graphicsHelpers.printCentered({msg})
end

function countdownAnimationClass:roundCanStart()
  return self.countdownTimer:isElapsed()
end

function countdownAnimationClass:start()
  self.countdownTimer:start()
end

return countdownAnimationModule
