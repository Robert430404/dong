local systemConfig = {}

function systemConfig:getScreenWidth()
  return love.graphics.getWidth()
end

function systemConfig:getScreenHeight()
  return love.graphics.getHeight()
end

function systemConfig:getTargetFrames()
  return 60
end

return systemConfig