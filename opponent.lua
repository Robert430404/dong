local opponent = {
	isEnabled = false,
	reactionSteps = 9,
	speedFactor = 0.85,
	errorFraction = 0.12,
	stepsUntilReaction = 0,
	targetY = nil
}

function opponent:reset()
	self.stepsUntilReaction = 0
	self.targetY = nil
end

function opponent:setStatus(isEnabled)
	self.isEnabled = isEnabled
	self:reset()
end

function opponent:run(gameState)
	if not self.isEnabled then
		return
	end

	self.stepsUntilReaction = self.stepsUntilReaction - 1
	if self.stepsUntilReaction <= 0 then
		self.stepsUntilReaction = self.reactionSteps
		self:chooseTarget(gameState)
	end

	self:moveTowardTarget(gameState)
end

function opponent:chooseTarget(gameState)
	local ball = gameState.ball
	local velocity = gameState.ballVelocity
	local target = (gameState.upperBoundary + gameState.lowerBoundary) / 2

	if ball.isMoving and velocity.x > 0 then
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

		local error = (math.random() * 2 - 1) * gameState.paddleHeight * self.errorFraction
		target = target + error
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
