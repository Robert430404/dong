local systemConfig = {}

function systemConfig:getScreenWidth()
	return 1280
end

function systemConfig:getScreenHeight()
	return 720
end

function systemConfig:getViewport()
	local windowWidth = love.graphics.getWidth()
	local windowHeight = love.graphics.getHeight()
	local scale = math.min(windowWidth / self:getScreenWidth(), windowHeight / self:getScreenHeight())
	local offsetX = (windowWidth - self:getScreenWidth() * scale) / 2
	local offsetY = (windowHeight - self:getScreenHeight() * scale) / 2

	return scale, offsetX, offsetY
end

function systemConfig:getTargetFrames()
	return 60
end

return systemConfig
