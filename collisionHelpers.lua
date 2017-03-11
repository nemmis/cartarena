local collisionHelperModule = {}

-- @brief return true if a player collides with a bullet
function collisionHelperModule.isVehicleBulletCollision(collisionShape, otherCollisionShape)
  if collisionShape.isAVehicle and otherCollisionShape.isABullet then return true end
  if collisionShape.isABullet and otherCollisionShape.isAVehicle then return true end
  return false
end

return collisionHelperModule
