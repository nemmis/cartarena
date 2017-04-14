local utils = {}

function utils.isTable(var)
  return type(var) == "table"
end

function utils.isFunction(var)
  return type(var) == "function"
end

function utils.isString(var)
  return type(var) == "string"
end

function utils.assertTypeTable(var)
  assert(utils.isTable(var), "Input must be a table but is a " .. type(var))
end

function utils.assertTypeString(var)
  assert(utils.isString(var), "Input must be a string but is a " .. type(var))
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

function utils.assertTypeFunction(var, msg)
  local assertMsg = msg or string.format("Input must be function but is a %s.", type(var))
  assert(utils.isFunction(var), assertMsg)
end

return utils
