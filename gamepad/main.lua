-- Test for gamepads
-- See when joysticks are connected / disconnected using callbacks
-- When a joystick is disconnected then reconnected its id remains stable
-- The player has one gamepad
-- The last button pressed on any gamepad is displayed
-- Can exit the game using the back button of the controller

local lastButtonPressed = "none"
local player = { hasGamepad = false, gamepad = nil}

function love.load()
  local joystickCount = love.joystick.getJoystickCount()
  print("There are " .. joystickCount .. " joysticks connected at game launch")

  local joysticks = love.joystick.getJoysticks()
  for i, joystick in ipairs(joysticks)
  do
    print('Joystick' .. i .. ': ' .. toStringJoystick(joystick))
  end

-- see gamepad mappings
  local mappings = love.joystick.saveGamepadMappings( )
  print("Gamepad mappings: " .. mappings)
  print('love.load finished')
end

function love.update(dt)

  -- exit if back is pressed
  if player.hasGamepad and player.gamepad:isGamepadDown('back')
  then love.event.quit()
  end

end

function love.draw()
  -- display the last button pressed
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Last button of the gamepad pressed: " .. lastButtonPressed, 5, 5)
end

-- callbacks
-- can be used to handle disconnection
-- called after love.load
function love.joystickadded(joystick)
  print('Joystick added: ' .. toStringJoystick(joystick))
  -- add the joystick to the player if needed
  if joystick:isGamepad() and not player.hasGamepad
  then player.hasGamepad = true
    player.gamepad = joystick
    print("Gamepad assigned to the player")
  end

end

function love.joystickremoved(joystick)
  print('Joystick removed: ' .. toStringJoystick(joystick))

  -- check if the joystick from the player was removed
  if player.gamepad:getID() == joystick:getID()
    then player.gamepad = nil
      player.hasGamepad = false
      print("Gamepad removed from player")
    end
end

function love.gamepadpressed(joystick, button)
  print("Last button pressed by any gamepad: " .. button)
  lastButtonPressed = button
end

-- utils
function toStringJoystick(joystick)
  return "name(" .. joystick:getName() .. "), isGamepad(" .. tostring(joystick:isGamepad()) .. "), stable_id(" .. joystick:getID() .. "), GUID(" .. joystick:getGUID() .. ")"
end
