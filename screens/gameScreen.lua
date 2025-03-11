local systemConfig = require 'config.systemConfig'

local gameScreen = {
	paddleVelocity = 8,
	paddleGap = 8,
	paddleWidth = 20,
	paddleHeight = 200,
	leftPaddle = {
		x = 0,
		y = 0
	},
	rightPaddle = {
		x = 0,
		y = 0
	},

	ballVelocity = 1,
	ball = {
		x = 100,
		y = 100,
		height = 20,
		width = 20
	}
}

local maxVerticalOffset = systemConfig:getScreenHeight() - gameScreen.paddleHeight - gameScreen.paddleGap;

-- Handle fullscreen shift and recalculate the math
function gameScreen:handleFullscreen() 
	leftHorizontalOffset = gameScreen.paddleGap
	leftVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.paddleHeight / 2)

	rightHorizontalOffset = systemConfig:getScreenWidth() - gameScreen.paddleWidth - gameScreen.paddleGap
	rightVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.paddleHeight / 2)

	ballHorizontalOffset = (systemConfig:getScreenWidth() / 2) - (gameScreen.ball.width / 2)
	ballVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.ball.height / 2)

	gameScreen.leftPaddle.x = leftHorizontalOffset
	gameScreen.leftPaddle.y = leftVerticalOffset

	gameScreen.rightPaddle.x = rightHorizontalOffset
	gameScreen.rightPaddle.y = rightVerticalOffset

	gameScreen.ball.x = ballHorizontalOffset
	gameScreen.ball.y = ballVerticalOffset

	-- Set the global
	maxVerticalOffset = systemConfig:getScreenHeight() - gameScreen.paddleHeight - gameScreen.paddleGap;
end

-- Render the screen
function gameScreen:render()
	love.graphics.setColor( love.math.colorFromBytes(46, 207, 133) )
	self:drawPaddle(self.leftPaddle.x, self.leftPaddle.y)
	self:drawPaddle(self.rightPaddle.x, self.rightPaddle.y)

	love.graphics.setColor( love.math.colorFromBytes(246, 207, 133) )
	self:drawBall(self.ball.x, self.ball.y)
end

function gameScreen:drawPaddle(x, y)
	love.graphics.rectangle( "fill", x, y, self.paddleWidth, self.paddleHeight )
end

function gameScreen:drawBall(x, y)
	love.graphics.rectangle( "fill", x, y, self.ball.width, self.ball.height )
end

function gameScreen:handleKeypresses(key, scancode, isrepeat)
	if key == "w" then
		local computed = self.leftPaddle.y - self.paddleVelocity

		if computed < self.paddleGap then
			self.leftPaddle.y = self.paddleGap
		else
	  	self.leftPaddle.y = computed
		end
  end

  if key == "s" then
		local computed = self.leftPaddle.y + self.paddleVelocity

		if computed > maxVerticalOffset then
			self.leftPaddle.y = maxVerticalOffset
		else
	  	self.leftPaddle.y = computed
	  end
  end

  if key == "up" then
		local computed = self.rightPaddle.y - self.paddleVelocity

		if computed < 8 then
			self.rightPaddle.y = self.paddleGap
		else
	  	self.rightPaddle.y = computed
		end
  end

  if key == "down" then
		local computed = self.rightPaddle.y + self.paddleVelocity

		if computed > maxVerticalOffset then
			self.rightPaddle.y = maxVerticalOffset
		else
	  	self.rightPaddle.y = computed
	  end
  end
end

function gameScreen:handleHeldkey(isDown)
	if isDown("w") then
		self:handleKeypresses("w", "", "")
	end

	if isDown("s") then
		self:handleKeypresses("s", "", "")
	end

	if isDown("up") then
		self:handleKeypresses("up", "", "")
	end

	if isDown("down") then
		self:handleKeypresses("down", "", "")
	end
end

return gameScreen