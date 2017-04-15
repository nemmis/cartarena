--[[

= post round animation

"Round ended !"

]]
local timerModule = require 'timer'
local graphicsHelpers = require 'graphicsHelpers'

local postRoundAnimationModule = {}

local postRoundAnimationClass = {}

function postRoundAnimationModule.newPostRoundAnimation()
  local anim = {}

  anim.timer = timerModule.new(2000)

  setmetatable(anim, {__index = postRoundAnimationClass})

  return anim
end

function postRoundAnimationClass:update(dt)
  self.timer:update(dt)
end

--only draw something if the animation is running
function postRoundAnimationClass:draw()
  if self.timer:isRunning() then
    graphicsHelpers.bigPrint()
    local msg = string.format("Round ended !")
    graphicsHelpers.printCentered({msg})
  end
end

function postRoundAnimationClass:isFinished()
  return self.timer:isElapsed()
end

function postRoundAnimationClass:start()
  self.timer:start()
end

function postRoundAnimationClass:isRunning()
  return self.timer:isRunning()
end

return postRoundAnimationModule
