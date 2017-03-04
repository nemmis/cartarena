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
