local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'

local scoreFont = love.graphics.newFont( "assets/doto-regular.ttf", 48 )

local gameScreen = {
	upperBoundary = 0,
	lowerBoundary = 0,

	lastLoss = 'none',
	lossMarker = {
		x = 0,
		y = 0
	},

	scores = {
		left = {
			value = love.graphics.newText( scoreFont, "L0 W0" ),
			score = 0,
			x = 0,
			y = 0
		},
		right = {
			value = love.graphics.newText( scoreFont, "L0 W0" ),
			score = 0,
			x = 0,
			y = 0
		}
	},

	divider = {
		x = 0,
		y = 0,
		width = 0,
		height = 0
	},

	offsetGap = 12,

	paddleVelocity = 8,
	paddleWidth = 0,
	paddleHeight = 0,
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
		direction = {
			x = 'right',
			y = 'none'
		},
		initialVelocity = 8,
		maxXVelocity = 30,
		maxYVelocity = 30,
		velocityCompoundFactor = 2
	},

	maxVerticalOffset = 0
}

gameScreen.maxVerticalOffset = systemConfig:getScreenHeight() - gameScreen.paddleHeight - gameScreen.offsetGap

-- Handle fullscreen shift and recalculate the math
function gameScreen:handleFullscreen()
	local centerLine = (systemConfig:getScreenWidth() / 2)

	-- Calculate divider dimensions
	self.divider.height = systemConfig:getScreenHeight()
	self.divider.width = self.divider.height / 20
	self.divider.x = centerLine - (self.divider.width / 2)
	self.divider.y = 0

	-- Calculate score dimensions
	self.scores.left.x = (centerLine / 2) - (self.scores.left.value:getWidth() / 2)
	self.scores.left.y = self.offsetGap
	self.scores.right.x = centerLine + (centerLine / 2) - (self.scores.right.value:getWidth() / 2)
	self.scores.right.y = self.offsetGap

	-- Calculate paddle dimensions
	self.paddleHeight = systemConfig:getScreenHeight() / 4
	self.paddleWidth = self.paddleHeight / 10

	self.paddleVelocity = self.paddleHeight / 10

	self.ball.height = self.paddleHeight / 10
	self.ball.width = self.paddleHeight / 10

	-- Compute the baseline offsets
	leftHorizontalOffset = self.offsetGap
	leftVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.paddleHeight / 2)

	rightHorizontalOffset = systemConfig:getScreenWidth() - self.paddleWidth - self.offsetGap
	rightVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.paddleHeight / 2)

	-- Set the game state
	self.leftPaddle.x = leftHorizontalOffset
	self.leftPaddle.y = leftVerticalOffset

	self.rightPaddle.x = rightHorizontalOffset
	self.rightPaddle.y = rightVerticalOffset

	self.upperBoundary = self.offsetGap
	self.lowerBoundary = systemConfig:getScreenHeight() - self.offsetGap

	self:centerBall()

	-- Set the global
	self.maxVerticalOffset = systemConfig:getScreenHeight() - self.paddleHeight - self.offsetGap
end

function gameScreen:advanceFrame()
	opponent:run(self)

	if self.ball.isMoving then
		self:calculateBallPosition()
	end

	if self:ballDidCollide() then
		self:handleBallVelocity()
	end
end

-- Render the screen
function gameScreen:render()
	love.graphics.setColor( love.math.colorFromBytes(44, 44, 44) )
	self:drawDivider(self.divider.x, self.divider.y)

	if self.lastLoss == 'none' then else
		love.graphics.setColor( love.math.colorFromBytes(99, 22, 22) )
		self:drawLossMarker()
	end

	love.graphics.setColor( love.math.colorFromBytes(122, 122, 122) )
	self:drawScores(self.scores.left, self.scores.right)

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

function gameScreen:drawDivider(x, y)
	love.graphics.rectangle( "fill", x, y, self.divider.width, self.divider.height )
end

function gameScreen:drawScores(left, right)
	love.graphics.draw( left.value, left.x, left.y )
	love.graphics.draw( right.value, right.x, right.y )
end

function gameScreen:centerBall()
	ballHorizontalOffset = (systemConfig:getScreenWidth() / 2) - (self.ball.width / 2)
	ballVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.ball.height / 2)

	self.ball.x = ballHorizontalOffset
	self.ball.y = ballVerticalOffset
end

function gameScreen:drawLossMarker()
	local lastLoss = self.scores[self.lastLoss]

	love.graphics.rectangle( "fill", lastLoss.x - 2, lastLoss.y + lastLoss.value:getHeight(), lastLoss.value:getWidth(), self.offsetGap )
end

function gameScreen:calculateBallPosition()
	local computedX
	if self.ball.direction.x == 'left' then
		computedX = self.ball.x - self.ballVelocity.x
	else
		computedX = self.ball.x + self.ballVelocity.x
	end

	self.ball.x = computedX

	local computedY
	if self.ball.direction.y == 'up' then
		computedY = self.ball.y - self.ballVelocity.y
	elseif self.ball.direction.y == 'down' then
		computedY = self.ball.y + self.ballVelocity.y
	else
		computedY = self.ball.y
	end

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

		self:handleLeftPaddleCollision()

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

		self:handleRightPaddleCollision()

		return true
	end

	return false
end

function gameScreen:handleLeftPaddleCollision()
	self:handleBallAngle(self.leftPaddle, 'left')
end

function gameScreen:handleRightPaddleCollision()
	self:handleBallAngle(self.rightPaddle, 'right')
end

function gameScreen:handleBallAngle(paddle, side)
	local ball = self.ball
	local computedBallPosition = (ball.y + ball.height) - paddle.y
	local percentageOfPaddle = (computedBallPosition / self.paddleHeight) * 100

	if percentageOfPaddle < 40 then
		self.ball.direction.y = 'up'
		self.ballVelocity.y = (1 * percentageOfPaddle) / 10
	elseif percentageOfPaddle > 60 then
		local computedBallVelocity = 1 * (percentageOfPaddle - 60)

		self.ball.direction.y = 'down'
		self.ballVelocity.y = computedBallVelocity / 10
	else
		self.ball.direction.y = 'none'
		self.ballVelocity.y = 0
	end

	if side == 'left' then
		self.ball.direction.x = 'right'
		self.ball.x = paddle.x + self.ball.width
	else
		self.ball.direction.x = 'left'
		self.ball.x = paddle.x - self.ball.width
	end
end

function gameScreen:handleBallVelocity()
	local maxXVelocity = self.ball.maxXVelocity
	local maxYVelocity = self.ball.maxYVelocity
	local compoundFactor = self.ball.velocityCompoundFactor

	local velocityX = self.ballVelocity.x
	local velocityY = self.ballVelocity.y

	local computedX = velocityX + compoundFactor
	if computedX >= maxXVelocity then
		self.ballVelocity.x = self.ballVelocity.x
	else
		self.ballVelocity.x = computedX
	end

	local computedY = velocityY + compoundFactor
	if computedY >= maxYVelocity then
		self.ballVelocity.y = self.ballVelocity.y
	else
		self.ballVelocity.y = computedY
	end
end

function gameScreen:handleLoss(side)
	self.ball.isMoving = false
	self.lastLoss = side

	self:centerBall()

	self.ballVelocity.x = 0
	self.ballVelocity.y = 0

	if side == 'left' then
		self.scores.right.score = self.scores.right.score + 1
	else
		self.scores.left.score = self.scores.left.score + 1
	end

	self.scores.left.value:set( string.format("L%s W%s", self.scores.right.score, self.scores.left.score) )
	self.scores.right.value:set( string.format("L%s W%s", self.scores.left.score, self.scores.right.score) )

	self:handleFullscreen()
end

function gameScreen:handleKeypresses(key, scancode, isrepeat)
	if key == "space" and self.ball.isMoving == false then
		self.ballVelocity.x = self.lastLoss == 'right' and 4 or -4
		if self.lastLoss == 'none' then
			self.ballVelocity.x = self.ball.initialVelocity
		end

		self.ball.isMoving = true
	end

	if key == "w" then
		local computed = self.leftPaddle.y - self.paddleVelocity

		if computed < self.offsetGap then
			self.leftPaddle.y = self.offsetGap
		else
			self.leftPaddle.y = computed
		end
	end

	if key == "s" then
		local computed = self.leftPaddle.y + self.paddleVelocity

		if computed > self.maxVerticalOffset then
			self.leftPaddle.y = self.maxVerticalOffset
		else
			self.leftPaddle.y = computed
		end
	end

	if opponent.isEnabled then
		return
	end

	if key == "up" then
		local computed = self.rightPaddle.y - self.paddleVelocity

		if computed < 8 then
			self.rightPaddle.y = self.offsetGap
		else
			self.rightPaddle.y = computed
		end
	end

	if key == "down" then
		local computed = self.rightPaddle.y + self.paddleVelocity

		if computed > self.maxVerticalOffset then
			self.rightPaddle.y = self.maxVerticalOffset
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