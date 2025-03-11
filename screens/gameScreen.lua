local systemConfig = require 'config.systemConfig'

local gameScreen = {
	paddleGap = 8,
	paddleWidth = 30,
	paddleHeight = 200,
	leftPaddle = {
		x = 0,
		y = 0
	},
	rightPaddle = {
		x = 0,
		y = 0
	}
}

-- Handle fullscreen shift and recalculate the math
function gameScreen:handleFullscreen() 
	leftHorizontalOffset = gameScreen.paddleGap
	leftVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.paddleHeight / 2)

	rightHorizontalOffset = systemConfig:getScreenWidth() - gameScreen.paddleWidth - gameScreen.paddleGap
	rightVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.paddleHeight / 2)

	gameScreen.leftPaddle.x = leftHorizontalOffset
	gameScreen.leftPaddle.y = leftVerticalOffset

	gameScreen.rightPaddle.x = rightHorizontalOffset
	gameScreen.rightPaddle.y = rightVerticalOffset
end

-- Render the screen
function gameScreen:render()
	love.graphics.setColor( love.math.colorFromBytes(46, 207, 133) )
	
	self:drawPaddle(self.leftPaddle.x, self.leftPaddle.y)

	self:drawPaddle(self.rightPaddle.x, self.rightPaddle.y)
end

function gameScreen:drawPaddle(x, y)
	love.graphics.rectangle( "fill", x,y, self.paddleWidth, self.paddleHeight )
end

return gameScreen