local systemConfig = {}

function systemConfig:getScreenWidth()
  return love.graphics.getWidth()
end

function systemConfig:getScreenHeight()
  return love.graphics.getHeight()
end

-- Computes the maximum value for the right offset
function systemConfig:getMaxRight(offset)
  return self:getScreenWidth() - (offset or 0)
end

-- Computes the maximum vlaue for the left offset
function systemConfig:getMaxBottom(offset)
  return self:getScreenHeight() - (offset or 0)
end

-- Cap the frames
function love.update(dt)
  if dt <= 1 / 60 then
    love.timer.sleep(0.001)
  end
end

return systemConfig