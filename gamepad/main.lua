-- Test for gamepads
-- See when joystick are connected / disconnected using callbacks
-- When a joystick is disconnected then reconnected the id remains stable

function love.load()
  joystickCount = love.joystick.getJoystickCount()
  print("There are " .. joystickCount .. " joysticks connected at game launch")

  joysticks = love.joystick.getJoysticks()
  for i, joystick in ipairs(joysticks)
  do
    print('Joystick' .. i .. ': ' .. toStringJoystick(joystick))
  end

  print('love.load finished')
end

function love.update(dt)

end

function love.render()

end

-- callbacks
-- can be used to handle disconnection and
function love.joystickadded(joystick)
  print('Joystick added: ' .. toStringJoystick(joystick))
end

function love.joystickremoved(joystick)
  print('Joystick removed: ' .. toStringJoystick(joystick))
end

-- utils
function toStringJoystick(joystick)
  return "name(" .. joystick:getName() .. "), isGamepad(" .. tostring(joystick:isGamepad()) .. "), stable_id(" .. joystick:getID() .. "), GUID(" .. joystick:getGUID() .. ")"
end
