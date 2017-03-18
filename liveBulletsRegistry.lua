--[[
An object to handle live bullets
Bullets are added when they are fired by vehicles
Bullets are removed when they are picked by vehicles
]]


local bulletModule = require 'bullet'

local liveBulletRegistryModule = {}
local liveBulletRegistryClass = {}

----------------------------------------
-- Creates a new live bullet registry
----------------------------------------
function liveBulletRegistryModule.newLiveBulletRegistry()
  local bulletRegistry = {}

  bulletRegistry.bullets = {}
  bulletRegistry.debugging = false

  setmetatable(bulletRegistry, {__index = liveBulletRegistryClass})

  return bulletRegistry
end



function liveBulletRegistryClass:addFiredBullet(bullet)
  -- the bullet must be fired
  table.insert(self.bullets, bullet)
end

function liveBulletRegistryClass:removePickedBullet(bullet)
  local bulletIx = nil
  for index, bulletElement in ipairs(self.bullets) do
    if bulletElement == bullet then bulletIx = index end
  end

  if bulletIx ~= nil then
    table.remove(self.bullets, bulletIx)
  else
    print('BUG: remove a bullet unknow to the bullet registry')
  end
end

function liveBulletRegistryClass:update(dt)
  for _, bullet in pairs(self.bullets) do
    bullet:update(dt)
  end
end

function liveBulletRegistryClass:draw()
  for _, bullet in pairs(self.bullets) do
    bullet:draw()
  end
end

function liveBulletRegistryClass:setDebug(debugging)
  self.debugging = debugging
  for _, bullet in pairs(self.bullets) do
    bullet:setDebug(debugging)
  end
end

return liveBulletRegistryModule
