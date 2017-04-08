--[[

== IsHitEvent

An isHitEvent is sent by a vehicle when it is hit by a bullet.

The event references:
- the target: the character whose vehicle is hit by the bullet
- the shooter: the character that shot this bullet

When the shooter and the target are the same character, the character shot itself.

== IsHitEventListener

An isHitEventListener implements the function 'processIsHitEvent(event: IsHitEvent)'

]]

local utils = require 'utils'

local isHitEventModule = {}

local isHitEventClass = {}

function isHitEventModule.newIsHitEvent(target, shooter)
  utils.assertTypeTable(target)
  utils.assertTypeTable(shooter)

  local isHitEvent = {}
  isHitEvent.target = target
  isHitEvent.shooter = shooter

  setmetatable(isHitEvent, {__index = isHitEventClass})

  return isHitEvent
end

function isHitEventClass:getTarget()
  utils.assertTypeTable(self)
  return self.target
end

function isHitEventClass:getShooter()
  utils.assertTypeTable(self)
  return self.shooter
end

local function isIsHitEventListener(object)
  return utils.isTable(object) and utils.isFunction(object.processIsHitEvent)
end

function isHitEventModule.assertTypeIsHitEventListener(object)
  local msg = string.format(
    "The input is not of type IsHitEventListener (type = %s, processIsHitEvent = %s)",
    type(object),
    object.processIsHitEvent
  )
  assert(isIsHitEventListener(object), msg)
end

return isHitEventModule
