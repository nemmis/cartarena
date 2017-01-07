-- module for 2D geometry

local geometryLib = {}

function geometryLib.getNorm(x, y)
    return math.sqrt(x*x + y*y)
end

-- rotate a point or a vector of a positive or negative angle around the origin
function geometryLib.rotate(x, y, rotationAngle)
    local cosRotationAngle = math.cos(rotationAngle)
    local sinRotationAngle = math.sin(rotationAngle)
    return x * cosRotationAngle - y * sinRotationAngle, y * cosRotationAngle + x * sinRotationAngle
end

function geometryLib.translate(x, y, tx, ty)
    return x + tx, y + ty
end

local function localToGlobalPoint(xLocal, yLocal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    local x, y = geometryLib.rotate(xLocal, yLocal, rotationAngle)
    return geometryLib.translate(x, y, localOriginInGlobalX, localOriginInGlobalY)
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
    local x0Global, y0Global = localToGlobalPoint(0, 0, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    local x1Global, y1Global = localToGlobalPoint(dxLocal, dyLocal, localOriginInGlobalX, localOriginInGlobalY, rotationAngle)
    return getVector(x0Global, y0Global, x1Global, y1Global)
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
