-- a singleton to handle live bullets

local bulletModule = require 'bullet'

local liveBulletsRegistry = {
  bullets = {},
  debugging = false
}

function liveBulletsRegistry:addFiredBullet(bullet)
  -- the bullet must be fired
  table.insert(self.bullets, bullet)
end

function liveBulletsRegistry:removePickedBullet(bullet)
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

function liveBulletsRegistry:update(dt)
  for _, bullet in pairs(self.bullets) do
    bullet:update(dt)
  end
end

function liveBulletsRegistry:draw()
  for _, bullet in pairs(self.bullets) do
    bullet:draw()
  end
end

function liveBulletsRegistry:setDebug(debugging)
  self.debugging = debugging
  for _, bullet in pairs(self.bullets) do
    bullet:setDebug(debugging)
  end
end

return liveBulletsRegistry
