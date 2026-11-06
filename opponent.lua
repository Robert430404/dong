local difficulties = {
	easy = { reactionSteps = 30, speedFactor = 0.40, errorFraction = 1.00, ballSpeedFactor = 0.65 },
	normal = { reactionSteps = 21, speedFactor = 0.65, errorFraction = 0.50, ballSpeedFactor = 0.85 },
	hard = { reactionSteps = 9, speedFactor = 0.85, errorFraction = 0.12, ballSpeedFactor = 1.00 }
}

local opponent = {
	isEnabled = false,
	difficulty = 'normal',
	reactionSteps = difficulties.normal.reactionSteps,
	speedFactor = difficulties.normal.speedFactor,
	errorFraction = difficulties.normal.errorFraction,
	ballSpeedFactor = difficulties.normal.ballSpeedFactor,
	stepsUntilReaction = 0,
	targetY = nil,
	aimError = nil,
	random = math.random
}

function opponent:setDifficulty(name)
	local settings = difficulties[name]
	if not settings then
		return false
	end

	self.difficulty = name
	self.reactionSteps = settings.reactionSteps
	self.speedFactor = settings.speedFactor
	self.errorFraction = settings.errorFraction
	self.ballSpeedFactor = settings.ballSpeedFactor
	self:reset()
	return true
end

function opponent:reset()
	self.stepsUntilReaction = 0
	self.targetY = nil
	self.aimError = nil
	self.trackedBall = nil
end

function opponent:setStatus(isEnabled)
	self.isEnabled = isEnabled
	self:reset()
end

function opponent:findIncomingBall(gameState)
	local nearest = nil
	local nearestTime = math.huge

	for _, entry in ipairs(gameState.balls) do
		local ball = entry.ball
		local velocity = entry.velocity
		if ball.isMoving and velocity.x > 0 then
			local distance = gameState.rightPaddle.x - ball.width - ball.x
			local arrivalTime = math.max(0, distance / velocity.x)
			if arrivalTime < nearestTime then
				nearest = entry
				nearestTime = arrivalTime
			end
		end
	end

	return nearest
end

function opponent:run(gameState)
	if not self.isEnabled then
		return
	end

	local incoming = self:findIncomingBall(gameState)
	local incomingBall = nil
	if incoming then
		incomingBall = incoming.ball
	end

	if incomingBall ~= self.trackedBall then
		self.trackedBall = incomingBall
		self.aimError = nil
		self.stepsUntilReaction = 0
	end

	self.stepsUntilReaction = self.stepsUntilReaction - 1
	if self.stepsUntilReaction <= 0 then
		self.stepsUntilReaction = self.reactionSteps
		self:chooseTarget(gameState, incoming)
	end

	self:moveTowardTarget(gameState)
end

function opponent:chooseTarget(gameState, incoming)
	local target = (gameState.upperBoundary + gameState.lowerBoundary) / 2

	if incoming then
		local ball = incoming.ball
		local velocity = incoming.velocity
		local distance = gameState.rightPaddle.x - ball.width - ball.x
		local travel = math.max(0, distance / velocity.x)
		local upperBound = gameState.upperBoundary
		local range = gameState.lowerBoundary - ball.height - upperBound

		if range > 0 then
			local projected = (ball.y - upperBound + velocity.y * travel) % (2 * range)
			if projected > range then
				projected = 2 * range - projected
			end

			target = upperBound + projected + ball.height / 2
		end

		if not ball.isOpeningServe then
			if self.aimError == nil then
				self.aimError = self.random() * 2 - 1
			end

			local error = self.aimError * gameState.paddleHeight * self.errorFraction
			target = target + error
		end
	end

	local targetY = target - gameState.paddleHeight / 2
	self.targetY = math.max(gameState.offsetGap, math.min(gameState.maxVerticalOffset, targetY))
end

function opponent:moveTowardTarget(gameState)
	local difference = self.targetY - gameState.rightPaddle.y
	local speed = gameState.paddleVelocity * self.speedFactor

	if math.abs(difference) > 2 then
		local movement = math.max(-speed, math.min(speed, difference))
		gameState:movePaddle(gameState.rightPaddle, movement)
	end
end

return opponent
