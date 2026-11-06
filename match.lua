local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'
local powerUpManager = require 'powerups.manager'
local ballPhysics = require 'ballPhysics'

local match = {
	upperBoundary = 0,
	lowerBoundary = 0,

	lastLoss = 'none',
	lossMarker = {
		x = 0,
		y = 0
	},

	scores = {
		left = {
			score = 0
		},
		right = {
			score = 0
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

	maxVerticalOffset = 0
}

match.pendingMovement = {}
match.balls = {
	{
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
		velocity = { x = 0, y = 0 }
	}
}
match.powerUps = powerUpManager:new()

-- Compatibility accessors derive the primary ball from the collection, never a second copy.
setmetatable(match, {
	__index = function(self, key)
		if key == 'ball' then
			return self.balls[1].ball
		end
		if key == 'ballVelocity' then
			return self.balls[1].velocity
		end
	end
})

match.maxVerticalOffset = systemConfig:getScreenHeight() - match.paddleHeight - match.offsetGap

-- Handle fullscreen shift and recalculate the math
function match:handleFullscreen()
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

function match:advanceFrame()
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
			ballPhysics:advance(self, entry)
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
	elseif ballsAtStart > 0 and self.rallyInProgress then
		self:resetRally()
	end
end

function match:centerBall()
	local ballHorizontalOffset = (systemConfig:getScreenWidth() / 2) - (self.ball.width / 2)
	local ballVerticalOffset = (systemConfig:getScreenHeight() / 2) - (self.ball.height / 2)

	self.ball.x = ballHorizontalOffset
	self.ball.y = ballVerticalOffset
end

function match:addBall(ball, velocity, speedBoost)
	table.insert(self.balls, { ball = ball, velocity = velocity, speedBoost = speedBoost })
end

function match:handleLoss(side, entry)
	entry.ball.isMoving = false
	self.lastLoss = side

	if side == 'left' then
		self.scores.right.score = self.scores.right.score + 1
	else
		self.scores.left.score = self.scores.left.score + 1
	end

end

function match:resetRally()
	self.rallyInProgress = false
	self.ball.isMoving = false
	self.ballVelocity.x = 0
	self.ballVelocity.y = 0
	self.balls = { { ball = self.ball, velocity = self.ballVelocity } }
	self:centerBall()
	self.powerUps:reset(systemConfig:getTargetFrames())
	self:handleFullscreen()
end

function match:handleKeypresses(key, scancode, isrepeat)
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

function match:movePaddle(paddle, amount)
	paddle.y = math.max(self.offsetGap, math.min(self.maxVerticalOffset, paddle.y + amount))
end

function match:movementDirection(isDown, upKey, downKey)
	local direction = 0

	if isDown(upKey) or self.pendingMovement[upKey] then
		direction = direction - 1
	end

	if isDown(downKey) or self.pendingMovement[downKey] then
		direction = direction + 1
	end

	return direction
end

function match:handleHeldkey(isDown)
	local leftDirection = self:movementDirection(isDown, "w", "s")
	self:movePaddle(self.leftPaddle, leftDirection * self.paddleVelocity)

	if not opponent.isEnabled then
		local rightDirection = self:movementDirection(isDown, "up", "down")
		self:movePaddle(self.rightPaddle, rightDirection * self.paddleVelocity)
	end

	self.pendingMovement = {}
end

return match
