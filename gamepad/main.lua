-- Test for gamepads
-- See when joysticks are connected / disconnected using callbacks
-- When a joystick is disconnected then reconnected its id remains stable
-- The player has one gamepad
-- The last button pressed on any gamepad is displayed
-- Can exit the game using the back button of the controller

local lastButtonPressed = "none"
local player = { hasGamepad = false, gamepad = nil}
local rightThumbstick = { xAxis = 0, yAxis = 0}

function love.load()
  local major, minor, revision, codename = love.getVersion()
  local str = string.format("%d.%d.%d - %s", major, minor, revision, codename)
  print("Running LOVE version " .. str)

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

  if player.hasGamepad
  then

    -- exit if back is pressed
     if player.gamepad:isGamepadDown('back')
     then love.event.quit()
     end

     -- get the state of the right thumbstick
     rightThumbstick.xAxis = player.gamepad:getGamepadAxis("rightx")
     rightThumbstick.yAxis = player.gamepad:getGamepadAxis("righty")
 end

  -- get the status
end

function love.draw()
  -- display the last button pressed
  love.graphics.setColor(255, 255, 255)
  love.graphics.print("Last button of the gamepad pressed: " .. lastButtonPressed, 5, 5)

  renderThumbstick(rightThumbstick)
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
  print("Right thumbstick values: " .. rightThumbstick.xAxis .. " - " .. rightThumbstick.yAxis)
  lastButtonPressed = button
end

-- utils
function toStringJoystick(joystick)
  return "name(" .. joystick:getName() .. "), isGamepad(" .. tostring(joystick:isGamepad()) .. "), stable_id(" .. joystick:getID() .. "), GUID(" .. joystick:getGUID() .. ")"
end

function renderThumbstick(thumbstick)
  local scale = 50
  love.graphics.circle("fill", love.graphics.getWidth() / 2 + thumbstick.xAxis * scale, love.graphics.getHeight() / 2 + thumbstick.yAxis * scale, 2)
  love.graphics.circle("line", love.graphics.getWidth() / 2, love.graphics.getHeight() / 2, scale)
end
