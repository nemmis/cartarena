local geometry = require "geometryLib"

local vehicleInputModule = {}

local THUMBSTICK_SENSITIVITY = 0.15 -- thumbstick considered at rest if value in [-thumbstickSensitivity thumbstickSensitivity]

local INPUT_TYPE_THIRD_PERSON = "thirdPerson"
local INPUT_TYPE_FIRST_PERSON = "firstPerson"

function vehicleInputModule.TYPE_THIRD_PERSON()
  return INPUT_TYPE_THIRD_PERSON
end

function vehicleInputModule.TYPE_FIRST_PERSON()
  return INPUT_TYPE_FIRST_PERSON
end

local function steeringThirdPerson(thumbstickX, thumbstickY, x, y, theta)
  -- thumbstick axis mapped to vehicle local coordinate system
  local steeringXLocal, _ = geometry.globalToLocalVector(thumbstickX, thumbstickY, x, y, theta)

  -- as the vehicle coordinate is left handed, the sign as to be inversed
  -- > 0 to go right (negative value of x-axis), < 0 to go left (in direction of x-axis)
  return -steeringXLocal
end

-- TODO pass a transform object, is it already in love.graphics ?
-- accelerates and breaks are either 0 or 1 (digital input)
-- steeringDirection is in [-1 1], < 0 means left, > 0 means right
-- type: type of input, default value is first person
function vehicleInputModule.getDriverInput(gamepad, player, type)

  -- accelerates
  local accelerates = 0
  if gamepad:isGamepadDown('a')
  then accelerates = 1
  end

  -- breaks
  local breaks = 0
  if gamepad:isGamepadDown('b')
  then breaks = 1
  end

  -- steers
  local thumbstickXGlobal = gamepad:getGamepadAxis("leftx")
  local thumbstickYGlobal = gamepad:getGamepadAxis("lefty")

  local steeringDirection = thumbstickXGlobal -- first person view, player considered to be in the vehicle
  if type == INPUT_TYPE_THIRD_PERSON
  then steeringDirection = steeringThirdPerson(thumbstickXGlobal, thumbstickYGlobal, player.x, player.y, player.theta)
  end

  -- thumbstick is considered at rest in a small interval around 0 to avoid driving to be to sensitive
  if math.abs(steeringDirection) < THUMBSTICK_SENSITIVITY
  then steeringDirection = 0
  end

  return accelerates, breaks, steeringDirection
end

-- TODO third person view, all analog (for acceleration and breaking)

return vehicleInputModule
