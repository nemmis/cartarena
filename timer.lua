local timerModule = {}

local timerClass = {}

function timerModule.new(durationMs)

  local timer = {
    durationMs = durationMs,
    runs = false,
    elapsedMs = 0
  }

  setmetatable(timer, {__index = timerClass} )

  return timer
end

function timerClass:start()
  self.runs = true
end

function timerClass:stop()
  self.runs = false
end

function timerClass:update(dt)
  if self.runs then
    self.elapsedMs = self.elapsedMs + dt * 1000
  end
end

function timerClass:isElapsed()
  return self.elapsedMs > self.durationMs
end

function timerClass:reset()
  self.elapsedMs = 0
end

function timerClass:getRemainingMs()
  if not self:isElapsed() then
    return self.durationMs - self.elapsedMs
  else
    return 0
  end
end

return timerModule
