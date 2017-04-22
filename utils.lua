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

function utils.isNumber(var)
  return type(var) == "number"
end

function utils.isStrictlyPositiveNumber(var)
  return utils.isNumber(var) and var > 0
end

function utils.assertTypeTable(var)
  assert(utils.isTable(var), "Input must be a table but is a " .. type(var))
end

function utils.assertTypeString(var)
  assert(utils.isString(var), "Input must be a string but is a " .. type(var))
end

function utils.assertTypeNumber(var)
  assert(utils.isNumber(var), "Input must be a number but is a " .. type(var))
end

function utils.assertTypeStrictlyPositiveNumber(var)
  assert(utils.isStrictlyPositiveNumber(var), string.format("Input must be a strictly positive number but: type=%s, value=%s", type(var), var))
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
