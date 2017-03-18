local utils = {}

function utils.assertTypeTable(var)
  assert(type(var) == "table", "Input must be a table but is a " .. type(var))
end

function utils.assertTypeString(var)
  assert(type(var) == "string", "Input must be a string but is a " .. type(var))
end

return utils
