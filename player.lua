--[[

A player has a vehicle, bullets and a gamepad
It knows a live bullet registry that handles fired bullets.

== Shooting
- the player has an initial set of bullets
- when the right bumper of the gamepad is pressed, then the player fires a bullet
- the player can only fire if a bullet is available

== Picking up bullets
- the player can pick up bullets by moving over bullets that have stopped (pickable bullets)
- bullets that are picked up can be fired
- the player can pick up as many bullets as possible

== Elimination
0 the player is eliminated when it is shot
0 the bullet it holds can be picked
0 the bullet that shot the player stays at the collision point

]]

local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'

local playerModule = {}
local playerClass = {}
-- Creates a new player
-- @param debug is optional
function playerModule.new(x, y, gamepad, debug)
  local debugging = debug or false
  local vehicle = vehicleModule.new(x, y, 0, debug)

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
