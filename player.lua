--[[

A player has a vehicle, bullets and a gamepad
It knows a live bullet registry that handles fired bullets.

== Shooting
- the player has an initial set of bullets
- when the right bumper of the gamepad is pressed, then the player fires a bullet
- the player cannot only fire if a bullet is available

]]

local vehicleModule = require 'vehicle/vehicle'
local vehicleInput = require 'vehicleInput'
local bulletModule = require 'bullet'

-- singleton, used directly by all players
local liveBulletsRegistry = require 'liveBulletsRegistry'

local playerModule = {}
local playerClass = {}

local INITIAL_BULLET_COUNT = 3

-- Creates a new player
-- @param debug is optional
function playerModule.new(x, y, gamepad, debug)
  local debugging = debug or false
  local vehicle = vehicleModule.new(x, y, 0, debug)

  local player = {
    gamepad = gamepad,
    vehicle = vehicle,
    bullets = {},
    shotRequest = false -- we assume that there cannot be more than one shot request between two frames
  }

  -- add bullets
  for i = 1, INITIAL_BULLET_COUNT do
    table.insert(player.bullets, bulletModule.newPickedBullet())
  end

  setmetatable(player, {__index = playerClass} )

  return player
end

-- @returns nothing
function playerClass:update(dt)
  -- get driving inputs
  local accelerates, breaks, steers = vehicleInput.getDriverInput(self.gamepad, self.vehicle, vehicleInput.TYPE_THIRD_PERSON())

  -- update the vehicle
  self.vehicle:update(dt, accelerates, breaks, steers)

  -- process shot request
  if self.shotRequest then
    self:shoot()
    self.shotRequest = false
  end

end

-- @return a boolean that indicates if a player has bullets
function playerClass:hasBullets()
  return #self.bullets > 0
end

-- -- TODO finish implementing
-- function playerClass:pickUpBullet(bullet)
--   -- do not keep a bullet object
--   self.bulletCount = self.bulletCount + 1
--
--   -- destroy the bullet, a new one will be created when shooting
-- end

-- Shoot a bullet in the local Y direction if a bullet is available
-- @return a boolean that indicates if the player could shoot
function playerClass:shoot()
  if not self:hasBullets() then return false end;

  local firedBullet = table.remove(self.bullets)

  -- fire the bullet
  local bulletX, bulletY, bulletVx, bulletVy = self.vehicle:getBulletStartingPositionAndSpeedDirection()
  firedBullet:fire(bulletX, bulletY, bulletVx, bulletVy)
  liveBulletsRegistry:addFiredBullet(firedBullet)

  return true
end

-- called each time a key is pressed on a gamepad
function playerClass:gamepadPressed(gamepad, button)

  -- see if the event is for the current player
  -- check that this is the correct gamepad based on the gamepad ID
  if gamepad:getID() == self.gamepad:getID() then
    if gamepad:isGamepadDown('rightshoulder') then
        self.shotRequest = true
    end
  end
end


function playerClass:draw()
  self.vehicle:draw()
end

function playerClass:setDebug(debugging)
  self.vehicle:setDebug(debugging)
  for _, bullet in pairs(self.bullets) do
    bullet:setDebug(debugging)
  end
end




return playerModule
