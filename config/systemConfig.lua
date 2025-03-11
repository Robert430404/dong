local systemConfig = {}

function systemConfig:getScreenWidth()
  return love.graphics.getWidth()
end

function systemConfig:getScreenHeight()
  return love.graphics.getHeight()
end

return systemConfig