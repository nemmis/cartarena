--[[

A player has a vehicle, bullets and a gamepad

== Shooting
- the player has an initial set of bullets

]]

local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'

local playerModule = {}

local playerClass = {}

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
  -- inputs
  local accelerates, breaks, steers = vehicleInput.getDriverInput(self.gamepad, self.vehicle, vehicleInput.TYPE_THIRD_PERSON())

  -- vehicle
  self.vehicle:update(dt, accelerates, breaks, steers)
end

function playerClass:draw()
  self.vehicle:draw()
end

function playerClass:setDebug(debugging)
  self.vehicle:setDebug(debugging)
end

-- -- TODO finish implementing
-- function vehiclePrototype:pickUpBullet(bullet)
--   -- do not keep a bullet object
--   self.bulletCount = self.bulletCount + 1
--
--   -- destroy the bullet, a new one will be created when shooting
-- end
--
-- -- Shoot a bullet in the local Y direction if the player still has some
-- -- @return a reference to the newly created bullet
-- function vehiclePrototype:shoot()
--   -- create a bullet at a given position
--   if self.bulletCount > 0
--   then self.bulletCount = self.bulletCount - 1
--   end
--
--   return bulletModule.new(self.x, self.y + self.boundingRadius + bulletModule.getBulletRadius())
-- end


return playerModule
