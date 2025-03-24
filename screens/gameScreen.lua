local systemConfig = require 'config.systemConfig'

local gameScreen = {
	upperBoundary = 0,
	lowerBoundary = 0,

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

	ballVelocity = {
		x = 0,
		y = 0
	},
	ball = {
		x = 0,
		y = 0,
		height = 20,
		width = 20,
		isMoving = false,
		maxXVelocity = 15,
		maxYVelocity = 15,
		velocityCompoundFactor = 1.5
	}
}

local maxVerticalOffset = systemConfig:getScreenHeight() - gameScreen.paddleHeight - gameScreen.paddleGap

-- Handle fullscreen shift and recalculate the math
function gameScreen:handleFullscreen()
	-- Calculate paddle dimensions
	gameScreen.paddleHeight = systemConfig:getScreenHeight() / 3
	gameScreen.paddleWidth = gameScreen.paddleHeight / 10

	gameScreen.paddleVelocity = gameScreen.paddleHeight / 10

	gameScreen.ball.height = gameScreen.paddleHeight / 10
	gameScreen.ball.width = gameScreen.paddleHeight / 10

	-- Compute the baseline offsets
	leftHorizontalOffset = gameScreen.paddleGap
	leftVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.paddleHeight / 2)

	rightHorizontalOffset = systemConfig:getScreenWidth() - gameScreen.paddleWidth - gameScreen.paddleGap
	rightVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.paddleHeight / 2)

	-- Set the game state
	gameScreen.leftPaddle.x = leftHorizontalOffset
	gameScreen.leftPaddle.y = leftVerticalOffset

	gameScreen.rightPaddle.x = rightHorizontalOffset
	gameScreen.rightPaddle.y = rightVerticalOffset

	gameScreen.upperBoundary = self.paddleGap
	gameScreen.lowerBoundary = systemConfig:getScreenHeight() - self.paddleGap

	self:centerBall()

	-- Set the global
	maxVerticalOffset = systemConfig:getScreenHeight() - gameScreen.paddleHeight - gameScreen.paddleGap
end

function gameScreen:centerBall()
	ballHorizontalOffset = (systemConfig:getScreenWidth() / 2) - (gameScreen.ball.width / 2)
	ballVerticalOffset = (systemConfig:getScreenHeight() / 2) - (gameScreen.ball.height / 2)

	gameScreen.ball.x = ballHorizontalOffset
	gameScreen.ball.y = ballVerticalOffset
end

-- Render the screen
function gameScreen:render()
	if self.ball.isMoving then
		self:calculateBallPosition()
	end

	if self:ballDidCollide() then
		self:handleBallVelocity()
	end

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

function gameScreen:calculateBallPosition()
	local computedX = self.ball.x + self.ballVelocity.x
	self.ball.x = computedX

	local computedY = self.ball.y + self.ballVelocity.y
	self.ball.y = computedY
end

function gameScreen:ballDidCollide()
	local leftPaddle = self.leftPaddle
	local rightPaddle = self.rightPaddle
	local ball = self.ball

	-- Handle Bondary Collisions
	local hitCeiling = ball.y <= self.upperBoundary
	if hitCeiling then
		self.ballVelocity.y = self.ballVelocity.y * -1

		return false
	end

	local hitFloor = ball.y + ball.height >= self.lowerBoundary
	if hitFloor then
		self.ballVelocity.y = self.ballVelocity.y * -1

		return false
	end

	-- Coordinates Collided Left Paddle
	if ball.x <= (leftPaddle.x + self.paddleWidth) then
		local isBelowPaddle = ball.y > (leftPaddle.y + self.paddleHeight)
		local isAbovePaddle = ball.y + ball.height < leftPaddle.y
		if isBelowPaddle or isAbovePaddle then
			self:handleLoss("left")

			return false
		end

		local computedBallPosition = (ball.y + ball.height) - leftPaddle.y
		local isTopHalf = computedBallPosition < self.paddleHeight / 2
		if isTopHalf then
			print("left top half hit")
			print(self.ballVelocity.y)
			self.ballVelocity.y = self.ballVelocity.y == 0 and 0.15 or (self.ballVelocity.y * self.ball.velocityCompoundFactor) * -1
		else
			print("left bottom half hit")
			print(self.ballVelocity.y)
			self.ballVelocity.y = self.ballVelocity.y == 0 and -0.15 or self.ballVelocity.y * self.ball.velocityCompoundFactor
		end

		self.ball.x = leftPaddle.x + self.paddleWidth

		return true
	end

	-- Coordinates Collided Right Paddle
	if (ball.x + self.ball.width) >= rightPaddle.x then
		local isBelowPaddle = ball.y > (rightPaddle.y + self.paddleHeight)
		local isAbovePaddle = ball.y + ball.height < rightPaddle.y
		if isBelowPaddle or isAbovePaddle then
			self:handleLoss("right")

			return false
		end

		local computedBallPosition = (ball.y + ball.height) - rightPaddle.y
		local isTopHalf = computedBallPosition < self.paddleHeight / 2
		if isTopHalf then
			print("right top half hit")
			print(self.ballVelocity.y)
			self.ballVelocity.y = self.ballVelocity.y == 0 and 0.15 or self.ballVelocity.y * self.ball.velocityCompoundFactor
		else
			print("right bottom half hit")
			print(self.ballVelocity.y)
			self.ballVelocity.y = self.ballVelocity.y == 0 and -0.15 or (self.ballVelocity.y * self.ball.velocityCompoundFactor) * -1
		end

		self.ball.x = rightPaddle.x -  self.ball.width

		return true
	end

	return false
end

function gameScreen:handleBallVelocity()
	local maxXVelocity = self.ball.maxXVelocity
	local maxYVelocity = self.ball.maxYVelocity
	local compoundFactor = self.ball.velocityCompoundFactor

	local computedX = (self.ballVelocity.x * -1) * compoundFactor
	if computedX <= (maxXVelocity * -1) or computedX >= maxXVelocity then
		self.ballVelocity.x = self.ballVelocity.x * -1
	else
		self.ballVelocity.x = computedX
	end

	local computedY = (self.ballVelocity.y * -1) * compoundFactor
	if computedY <= (maxYVelocity * -1) or computedY >= maxYVelocity then
		self.ballVelocity.y = self.ballVelocity.y * -1
	else
		self.ballVelocity.y = computedY
	end
end

function gameScreen:handleLoss(side)
	self.ball.isMoving = false

	self:centerBall()

	self.ballVelocity.x = 0
	self.ballVelocity.y = 0

	print(side .. " lost the game")
end

function gameScreen:handleKeypresses(key, scancode, isrepeat)
	if key == "space" and self.ball.isMoving == false then
		self.ballVelocity.x = 4
		self.ball.isMoving = true
	end

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