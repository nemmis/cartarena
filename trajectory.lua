local trajectoryModule = {}

local colors = require "color"

local MAX_NUM_POINTS = 50

-- to store the methods of a trajectory object
local trajectoryPrototype = {}

function trajectoryModule.new()
  local trajectory = { points = {}, numPoints = 0 }
  setmetatable(trajectory, {__index = trajectoryPrototype})
  return trajectory
end

function trajectoryPrototype:add(px, py)
  -- insert at the beginning
  table.insert(self.points, 1, {px, py})
  self.numPoints = self.numPoints + 1

  -- remove last element if needed
  if self.numPoints > MAX_NUM_POINTS then
    table.remove(self.points)
    self.numPoints = self.numPoints - 1
  end

end

function trajectoryPrototype:draw()
  love.graphics.setColor(colors.WHITE())
  for i, point in ipairs(self.points) do
    love.graphics.points(point[1], point[2])
  end
end

return trajectoryModule
