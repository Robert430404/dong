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
	local oldWidth, oldHeight = self.layoutWidth, self.layoutHeight
	local oldLeftY, oldRightY = self.leftPaddle.y, self.rightPaddle.y
	local oldBallX, oldBallY = self.ball.x, self.ball.y
	self.layoutWidth, self.layoutHeight = systemConfig:getScreenWidth(), systemConfig:getScreenHeight()
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
	local leftHorizontalOffset = self.offsetGap
	local leftVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.paddleHeight / 2)

	local rightHorizontalOffset = systemConfig:getScreenWidth() - self.paddleWidth - self.offsetGap
	local rightVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.paddleHeight / 2)

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
	if oldWidth and oldHeight then
		self.leftPaddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, oldLeftY * self.layoutHeight / oldHeight))
		self.rightPaddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, oldRightY * self.layoutHeight / oldHeight))
		self.ball.x = math.max(self.leftPaddle.x + self.paddleWidth, math.min(self.rightPaddle.x - self.ball.width, oldBallX * self.layoutWidth / oldWidth))
		self.ball.y = math.max(self.upperBoundary, math.min(self.lowerBoundary - self.ball.height, oldBallY * self.layoutHeight / oldHeight))
	end
	opponent:reset()
end

function gameScreen:advanceFrame()
	opponent:run(self)

	if self.ball.isMoving then
		self:calculateBallPosition()
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
	local ballHorizontalOffset = (systemConfig:getScreenWidth() / 2) - (self.ball.width / 2)
	local ballVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.ball.height / 2)

	self.ball.x = ballHorizontalOffset
	self.ball.y = ballVerticalOffset
end

function gameScreen:drawLossMarker()
	local lastLoss = self.scores[self.lastLoss]

	love.graphics.rectangle( "fill", lastLoss.x - 2, lastLoss.y + lastLoss.value:getHeight(), lastLoss.value:getWidth(), self.offsetGap )
end

function gameScreen:calculateBallPosition()
	local ball = self.ball
	local velocity = self.ballVelocity
	local remaining = 1
	-- Process the earliest wall or paddle crossing, including multiple impacts in a step.
	while remaining > 0 and ball.isMoving do
		local time, event = remaining, nil
		local function consider(t, name)
			if t >= 0 and t <= time then time, event = t, name end
		end
		if velocity.y < 0 then
			consider((self.upperBoundary - ball.y) / velocity.y, 'wall')
		elseif velocity.y > 0 then
			consider((self.lowerBoundary - ball.height - ball.y) / velocity.y, 'wall')
		end
		if velocity.x < 0 then
			consider((self.leftPaddle.x + self.paddleWidth - ball.x) / velocity.x, 'left')
		elseif velocity.x > 0 then
			consider((self.rightPaddle.x - ball.width - ball.x) / velocity.x, 'right')
		end
		ball.x = ball.x + velocity.x * time
		ball.y = ball.y + velocity.y * time
		remaining = remaining - time
		if event == 'wall' then
			velocity.y = -velocity.y
		elseif event then
			local paddle = event == 'left' and self.leftPaddle or self.rightPaddle
			if ball.y > paddle.y + self.paddleHeight or ball.y + ball.height < paddle.y then
				self:handleLoss(event)
			else
				self:handleBallAngle(paddle, event)
			end
		else
			break
		end
	end
end

function gameScreen:handleBallAngle(paddle, side)
	local relative = ((self.ball.y + self.ball.height / 2) - (paddle.y + self.paddleHeight / 2)) / (self.paddleHeight / 2)
	relative = math.max(-1, math.min(1, relative))
	local speed = math.min(self.ball.maxXVelocity, math.abs(self.ballVelocity.x) + self.ball.velocityCompoundFactor)
	self.ballVelocity.x = side == 'left' and speed or -speed
	self.ballVelocity.y = relative * math.min(self.ball.maxYVelocity, speed * 0.75)
end

function gameScreen:handleLoss(side)
	self.ball.isMoving = false
	self.lastLoss = side

	self:centerBall()

	self.ballVelocity.x = 0
	self.ballVelocity.y = 0
	opponent:reset()

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
		self.ballVelocity.x = self.lastLoss == 'left' and -self.ball.initialVelocity or self.ball.initialVelocity

		self.ball.isMoving = true
	end

end

function gameScreen:movePaddle(paddle, amount)
	paddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, paddle.y + amount))
end

function gameScreen:handleHeldkey(isDown)
	local left = (isDown("s") and 1 or 0) - (isDown("w") and 1 or 0)
	self:movePaddle(self.leftPaddle, left * self.paddleVelocity)
	if not opponent.isEnabled then
		local right = (isDown("down") and 1 or 0) - (isDown("up") and 1 or 0)
		self:movePaddle(self.rightPaddle, right * self.paddleVelocity)
	end
end

return gameScreen
