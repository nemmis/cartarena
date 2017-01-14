-- module for 2D geometry

local geometryLib = {}

function geometryLib.getNorm(x, y)
    return math.sqrt(x*x + y*y)
end

-- rotate a point or a vector of a positive or negative angle around the origin
-- positive angle: clockwise, negative angle: counterclockwise
function geometryLib.rotate(x, y, rotationAngle)
    local cosRotationAngle = math.cos(rotationAngle)
    local sinRotationAngle = math.sin(rotationAngle)
    return x * cosRotationAngle - y * sinRotationAngle, y * cosRotationAngle + x * sinRotationAngle
end

-- translate a point by a constant vector
function geometryLib.translate(x, y, tx, ty)
    return x + tx, y + ty
end

function geometryLib.localToGlobalPoint(xLocal, yLocal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    local x, y = geometryLib.rotate(xLocal, yLocal, rotationAngle)
    return geometryLib.translate(x, y, localOriginInGlobalX, localOriginInGlobalY)
end

-- TODO rotate clockwise or counter clockwise ?
function geometryLib.globalToLocalPoint(xGlobal, yGlobal, localOriginInGlobalX, localOriginInGlobalY, rotationAngleLocal)
  -- for global to local coordinates start with point to transfrom in local coordinates system
  -- then rotate it of the opposite of the angle and translate it back
  local x, y = geometryLib.rotate(xGlobal, yGlobal, -rotationAngleLocal)
  return geometryLib.translate(x, y, -localOriginInGlobalX, -localOriginInGlobalY)
end

local function getVector(x0, y0, x1, y1)
    return x1 - x0, y1 - y0
end

function geometryLib.normalize(x, y, newNorm)
    -- TODO handle null vector
    local norm = geometryLib.getNorm(x, y)
    return x * newNorm / norm, y * newNorm / norm
end

function geometryLib.localToGlobalVector(dxLocal, dyLocal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    local x0Global, y0Global = geometryLib.localToGlobalPoint(0, 0, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    local x1Global, y1Global = geometryLib.localToGlobalPoint(dxLocal, dyLocal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    return getVector(x0Global, y0Global, x1Global, y1Global)
end

function geometryLib.globalToLocalVector(dxGlobal, dyGlobal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
  local x0Local, y0Local = geometryLib.globalToLocalPoint(0, 0, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
  local x1Local, y1Local = geometryLib.globalToLocalPoint(dxGlobal, dyGlobal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
  return getVector(x0Local, y0Local, x1Local, y1Local)
end

local function distance(ax, ay, bx, by)
    return math.sqrt((ax - bx) * (ax - bx) + (ay - by) * (ay - by))
end

function geometryLib.spheresIntersect(c0x, c0y, radius0, c1x, c1y, radius1)
    return distance(c0x, c0y, c1x, c1y) <= (radius0 + radius1)
end

function geometryLib.pointInSphere(x, y, cx, cy, radius)
    return distance(x, y, cx, cy) <= radius
end

function geometryLib.degreesToRadians(degrees)
    return degrees * math.pi / 180
end

return geometryLib
