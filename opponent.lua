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
	if not self.isEnabled then return end

	local ball = gameState.ball
	local velocity = gameState.ballVelocity
	self.stepsUntilReaction = self.stepsUntilReaction - 1
	if self.stepsUntilReaction <= 0 then
		self.stepsUntilReaction = self.reactionSteps
		local target = (gameState.upperBoundary + gameState.lowerBoundary) / 2
		if ball.isMoving and velocity.x > 0 then
			local travel = math.max(0, (gameState.rightPaddle.x - ball.width - ball.x) / velocity.x)
			local minY = gameState.upperBoundary
			local range = gameState.lowerBoundary - ball.height - minY
			if range > 0 then
				local projected = (ball.y - minY + velocity.y * travel) % (2 * range)
				target = minY + (projected <= range and projected or 2 * range - projected) + ball.height / 2
			end
			target = target + (math.random() * 2 - 1) * gameState.paddleHeight * self.errorFraction
		end
		self.targetY = math.max(gameState.offsetGap, math.min(gameState.maxVerticalOffset, target - gameState.paddleHeight / 2))
	end

	local difference = self.targetY - gameState.rightPaddle.y
	local speed = gameState.paddleVelocity * self.speedFactor
	if math.abs(difference) > 2 then
		gameState:movePaddle(gameState.rightPaddle, math.max(-speed, math.min(speed, difference)))
	end
end

return opponent
