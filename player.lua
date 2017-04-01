--[[

A player has a vehicle, bullets and a gamepad
It knows a live bullet registry that handles fired bullets.

]]

local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'
local utils = require 'utils'

local playerModule = {}
local playerClass = {}

------------------------------
-- Creates a new player
-- @param debug is optional
------------------------------
function playerModule.new(x, y, theta, bulletRegistry, color, gamepad, collider, debug)
  utils.assertTypeNumber(x)
  utils.assertTypeNumber(y)
  utils.assertTypeNumber(theta)
  utils.assertTypeTable(bulletRegistry)
  utils.assertTypeTable(color)
  utils.assertTypeUserdata(gamepad)
  utils.assertTypeTable(collider)
  utils.assertTypeOptionalBoolean(debug)

  local debugging = debug or false
  local vehicle = vehicleModule.new(x, y, theta, bulletRegistry, color, collider, debug)

  local player = {
    gamepad = gamepad,
    vehicle = vehicle
  }

  setmetatable(player, {__index = playerClass} )

  return player
end

-------------------------------------
-- Indicates that a player has lost
-------------------------------------
function playerClass:hasLost()
  return self.vehicle:isOutOfService()
end

------------------------------
-- Update the player
-- @returns nothing
------------------------------
function playerClass:update(dt)
  -- get driving inputs
  local accelerates, breaks, steers = vehicleInput.getDriverInput(self.gamepad, self.vehicle, vehicleInput.TYPE_THIRD_PERSON())

  -- update the vehicle
  self.vehicle:update(dt, accelerates, breaks, steers)

end

----------------------
-- Draw the player
----------------------
function playerClass:draw()
  self.vehicle:draw()
end

-----------------------------------------------------------------
-- Callback called each time a key is pressed on a gamepad
-----------------------------------------------------------------
function playerClass:gamepadPressed(gamepad, button)

  -- see if the event is for the current player
  -- check that this is the correct gamepad based on the gamepad ID
  if gamepad:getID() == self.gamepad:getID() then
    if gamepad:isGamepadDown('rightshoulder') then
        self.vehicle:shoot()
    end
  end
end



function playerClass:setDebug(debugging)
  self.vehicle:setDebug(debugging)
end

return playerModule
