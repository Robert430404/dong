local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'
local powerUpManager = require 'powerups.manager'

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

gameScreen.pendingMovement = {}
gameScreen.balls = { { ball = gameScreen.ball, velocity = gameScreen.ballVelocity } }
gameScreen.powerUps = powerUpManager:new()

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

	-- Set the paddle movement limit
	self.maxVerticalOffset = systemConfig:getScreenHeight() - self.paddleHeight - self.offsetGap
	if not self.powerUpsInitialized then
		self.powerUps:reset(systemConfig:getTargetFrames())
		self.powerUpsInitialized = true
	end
	if oldWidth and oldHeight then
		local heightScale = self.layoutHeight / oldHeight
		local widthScale = self.layoutWidth / oldWidth
		local leftY = oldLeftY * heightScale
		local rightY = oldRightY * heightScale
		local ballX = oldBallX * widthScale
		local ballY = oldBallY * heightScale
		local minBallX = self.leftPaddle.x + self.paddleWidth
		local maxBallX = self.rightPaddle.x - self.ball.width
		local maxBallY = self.lowerBoundary - self.ball.height

		self.leftPaddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, leftY))
		self.rightPaddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, rightY))
		self.ball.x = math.max(minBallX, math.min(maxBallX, ballX))
		self.ball.y = math.max(self.upperBoundary, math.min(maxBallY, ballY))
	end

	opponent:reset()
end

function gameScreen:advanceFrame()
	for _, entry in ipairs(self.balls) do
		if entry.ball.isMoving then
			self.powerUps:advanceFrame(self.balls, systemConfig:getScreenWidth(), systemConfig:getScreenHeight())
			break
		end
	end

	opponent:run(self)

	local ballsAtStart = #self.balls
	for index = 1, ballsAtStart do
		local entry = self.balls[index]
		if entry.ball.isMoving then
			self.rallyInProgress = true
			self:calculateBallPosition(entry)
		end
	end

	local activeBalls = {}
	for _, entry in ipairs(self.balls) do
		if entry.ball.isMoving then
			table.insert(activeBalls, entry)
		end
	end

	if #activeBalls > 0 then
		self.balls = activeBalls
		self.ball = activeBalls[1].ball
		self.ballVelocity = activeBalls[1].velocity
	elseif ballsAtStart > 0 and self.rallyInProgress then
		self:resetRally()
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

	self.powerUps:draw()

	love.graphics.setColor( love.math.colorFromBytes(246, 207, 133) )
	for _, entry in ipairs(self.balls) do
		self:drawBall(entry.ball)
	end
end

function gameScreen:drawPaddle(x, y)
	love.graphics.rectangle( "fill", x, y, self.paddleWidth, self.paddleHeight )
end

function gameScreen:drawBall(ball)
	love.graphics.rectangle( "fill", ball.x, ball.y, ball.width, ball.height )
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

function gameScreen:findNextCollision(remaining, ball, velocity)
	local collisionTime = remaining
	local collisionSide = nil

	local function considerCollision(time, side)
		if time >= 0 and time <= collisionTime then
			collisionTime = time
			collisionSide = side
		end
	end

	if velocity.y < 0 then
		considerCollision((self.upperBoundary - ball.y) / velocity.y, 'wall')
	elseif velocity.y > 0 then
		considerCollision((self.lowerBoundary - ball.height - ball.y) / velocity.y, 'wall')
	end

	if velocity.x < 0 then
		considerCollision((self.leftPaddle.x + self.paddleWidth - ball.x) / velocity.x, 'left')
	elseif velocity.x > 0 then
		considerCollision((self.rightPaddle.x - ball.width - ball.x) / velocity.x, 'right')
	end

	local item, itemTime = self.powerUps:findCollision(ball, velocity, remaining)
	if item and itemTime <= collisionTime then
		return itemTime, 'powerUp', item
	end

	return collisionTime, collisionSide
end

function gameScreen:calculateBallPosition(entry)
	local ball = entry.ball
	local velocity = entry.velocity
	local remaining = 1

	-- Resolve the earliest crossing first, including multiple impacts in a step.
	while remaining > 0 and ball.isMoving do
		local collisionTime, collisionSide, item = self:findNextCollision(remaining, ball, velocity)

		ball.x = ball.x + velocity.x * collisionTime
		ball.y = ball.y + velocity.y * collisionTime
		remaining = remaining - collisionTime

		if collisionSide == 'wall' then
			velocity.y = -velocity.y
		elseif collisionSide == 'powerUp' then
			self.powerUps:activate(item, self, entry)
		elseif collisionSide then
			local paddle = self.rightPaddle
			if collisionSide == 'left' then
				paddle = self.leftPaddle
			end

			if ball.y > paddle.y + self.paddleHeight or ball.y + ball.height < paddle.y then
				self:handleLoss(collisionSide, entry)
			else
				self:handleBallAngle(paddle, collisionSide, entry)
			end
		else
			break
		end
	end
end

function gameScreen:handleBallAngle(paddle, side, entry)
	local ball = entry.ball
	ball.isOpeningServe = false
	local velocity = entry.velocity
	local ballCenter = ball.y + ball.height / 2
	local paddleCenter = paddle.y + self.paddleHeight / 2
	local relativePosition = (ballCenter - paddleCenter) / (self.paddleHeight / 2)
	relativePosition = math.max(-1, math.min(1, relativePosition))

	local speedFactor = 1
	if opponent.isEnabled then
		speedFactor = opponent.ballSpeedFactor
	end

	local maxXVelocity = ball.maxXVelocity * speedFactor
	local maxYVelocity = ball.maxYVelocity * speedFactor
	local baseXVelocity = math.abs(velocity.x) / (entry.speedBoost or 1)
	entry.speedBoost = nil
	local speed = math.min(maxXVelocity, baseXVelocity + ball.velocityCompoundFactor)
	local verticalSpeed = math.min(maxYVelocity, speed * 0.75)
	if side == 'left' then
		velocity.x = speed
	else
		velocity.x = -speed
	end

	velocity.y = relativePosition * verticalSpeed
end

function gameScreen:addBall(ball, velocity, speedBoost)
	table.insert(self.balls, { ball = ball, velocity = velocity, speedBoost = speedBoost })
end

function gameScreen:handleLoss(side, entry)
	entry.ball.isMoving = false
	self.lastLoss = side

	if side == 'left' then
		self.scores.right.score = self.scores.right.score + 1
	else
		self.scores.left.score = self.scores.left.score + 1
	end

	self.scores.left.value:set( string.format("L%s W%s", self.scores.right.score, self.scores.left.score) )
	self.scores.right.value:set( string.format("L%s W%s", self.scores.left.score, self.scores.right.score) )

end

function gameScreen:resetRally()
	self.rallyInProgress = false
	self.ball.isMoving = false
	self.ballVelocity.x = 0
	self.ballVelocity.y = 0
	self.balls = { { ball = self.ball, velocity = self.ballVelocity } }
	self:centerBall()
	self.powerUps:reset(systemConfig:getTargetFrames())
	self:handleFullscreen()
end

function gameScreen:handleKeypresses(key, scancode, isrepeat)
	if key == "space" and not self.rallyInProgress and self.ball.isMoving == false then
		if self.lastLoss == 'left' then
			self.ballVelocity.x = -self.ball.initialVelocity
		else
			self.ballVelocity.x = self.ball.initialVelocity
		end

		self.ball.isMoving = true
		self.ball.isOpeningServe = true
		self.rallyInProgress = true
	end

	if not isrepeat and (key == "w" or key == "s" or key == "up" or key == "down") then
		self.pendingMovement[key] = true
	end
end

function gameScreen:movePaddle(paddle, amount)
	paddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, paddle.y + amount))
end

function gameScreen:movementDirection(isDown, upKey, downKey)
	local direction = 0

	if isDown(upKey) or self.pendingMovement[upKey] then
		direction = direction - 1
	end

	if isDown(downKey) or self.pendingMovement[downKey] then
		direction = direction + 1
	end

	return direction
end

function gameScreen:handleHeldkey(isDown)
	local leftDirection = self:movementDirection(isDown, "w", "s")
	self:movePaddle(self.leftPaddle, leftDirection * self.paddleVelocity)

	if not opponent.isEnabled then
		local rightDirection = self:movementDirection(isDown, "up", "down")
		self:movePaddle(self.rightPaddle, rightDirection * self.paddleVelocity)
	end

	self.pendingMovement = {}
end

return gameScreen
