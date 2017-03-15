--[[

A player has a vehicle, bullets and a gamepad
It knows a live bullet registry that handles fired bullets.

]]

local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'

local playerModule = {}
local playerClass = {}
-- Creates a new player
-- @param debug is optional
function playerModule.new(x, y, theta, gamepad, debug)
  local debugging = debug or false
  local vehicle = vehicleModule.new(x, y, theta, debug)

  local player = {
    gamepad = gamepad,
    vehicle = vehicle
  }

  setmetatable(player, {__index = playerClass} )

  return player
end

-- @returns nothing
function playerClass:update(dt)
  -- get driving inputs
  local accelerates, breaks, steers = vehicleInput.getDriverInput(self.gamepad, self.vehicle, vehicleInput.TYPE_THIRD_PERSON())

  -- update the vehicle
  self.vehicle:update(dt, accelerates, breaks, steers)

end

-- Callback called each time a key is pressed on a gamepad
function playerClass:gamepadPressed(gamepad, button)

  -- see if the event is for the current player
  -- check that this is the correct gamepad based on the gamepad ID
  if gamepad:getID() == self.gamepad:getID() then
    if gamepad:isGamepadDown('rightshoulder') then
        self.vehicle:shoot()
    end
  end
end

function playerClass:draw()
  self.vehicle:draw()
end

function playerClass:setDebug(debugging)
  self.vehicle:setDebug(debugging)
end

return playerModule
