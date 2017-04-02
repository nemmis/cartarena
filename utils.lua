local utils = {}

function utils.assertTypeTable(var)
  assert(type(var) == "table", "Input must be a table but is a " .. type(var))
end

function utils.assertTypeString(var)
  assert(type(var) == "string", "Input must be a string but is a " .. type(var))
end

function utils.assertTypeNumber(var)
  assert(type(var) == "number", "Input must be a number but is a " .. type(var))
end

function utils.assertTypeBoolean(var)
  assert(type(var) == "boolean", "Input must be a number but is a " .. type(var))
end

function utils.assertTypeOptionalBoolean(var)
  isOptionalBoolean = (type(var) == "nil") or (type(var) == "boolean")
  assert(isOptionalBoolean, "Input must be an optional boolean but is a " .. type(var))
end

function utils.assertTypeUserdata(var)
  assert(type(var) == "userdata", "Input must be userdata but is a " .. type(var))
end

return utils
