local opponent = {
	isEnabled = false,

	hasRolledForTurn = false,
	rollResult = nil
}

function opponent:run(gameState)
	if self.isEnabled == false then
		return
	end

	local ballUpperBound = gameState.ball.y
	local ballLowerBound = gameState.ball.y + gameState.ball.height

	local paddleUpperBound = gameState.rightPaddle.y
	local paddleLowerBound = gameState.rightPaddle.y + gameState.paddleHeight

	local isBallAbovePaddle = ballLowerBound < paddleUpperBound
	local isBallUnderPaddle = ballUpperBound > paddleLowerBound

	if isBallAbovePaddle then
		self:handleBallAbovePaddle(gameState)
	elseif isBallUnderPaddle then
		self:handleBallUnderPaddle(gameState)
	else
		self:handleBallInsideOfBounds(gameState)
	end
end

function opponent:handleBallAbovePaddle(gameState)
	local newPaddleY = gameState.rightPaddle.y - gameState.paddleVelocity

	if newPaddleY < 8 then
		gameState.rightPaddle.y = gameState.offsetGap
	else
		gameState.rightPaddle.y = newPaddleY
	end
end

function opponent:handleBallUnderPaddle(gameState)
	local computed = gameState.rightPaddle.y + gameState.paddleVelocity

	if computed > gameState.maxVerticalOffset then
		gameState.rightPaddle.y = gameState.maxVerticalOffset
	else
		gameState.rightPaddle.y = computed
	end
end

function opponent:handleBallInsideOfBounds(gameState)
	if gameState:ballDidCollide() then
		hasRolledForTurn = false
	end

	if hasRolledForTurn == false then
		self:determineVolleyTarget()

		hasRolledForTurn = true
	end

	self:handleVolleyTarget(gameState)
end

function opponent:determineVolleyTarget()
	math.randomseed(os.time())

	local randomNumber = math.random(1, 9)

	if randomNumber <= 3 then
		self.rollResult = 'upper_portion'
	elseif randomNumber >=4 and randomNumber <= 6 then
		self.rollResult = 'middle_portion'
	else
		self.rollResult = 'lower_portion'
	end
end

function opponent:handleVolleyTarget(gameState)
	local ballUpperBound = gameState.ball.y
	local ballLowerBound = gameState.ball.y + gameState.ball.height

	if self.rollResult == 'upper_portion' then
		local paddleUpperBound = gameState.rightPaddle.y
		local paddleLowerBound = gameState.rightPaddle.y + (gameState.paddleHeight / 3)

		local isBallAboveSegment = ballLowerBound < paddleUpperBound
		local isBallUnderSegment = ballUpperBound > paddleLowerBound

		if isBallAboveSegment then
			self:handleBallAbovePaddle(gameState)
		elseif isBallUnderSegment then
			self:handleBallUnderPaddle(gameState)
		end
	elseif self.rollResult == 'middle_portion' then
		local paddleUpperBound = gameState.rightPaddle.y + (gameState.paddleHeight / 3)
		local paddleLowerBound = gameState.rightPaddle.y + ((gameState.paddleHeight / 3) * 2)

		local isBallAboveSegment = ballLowerBound < paddleUpperBound
		local isBallUnderSegment = ballUpperBound > paddleLowerBound

		if isBallAboveSegment then
			self:handleBallAbovePaddle(gameState)
		elseif isBallUnderSegment then
			self:handleBallUnderPaddle(gameState)
		end
	else
		local paddleUpperBound = gameState.rightPaddle.y + ((gameState.paddleHeight / 3) * 2)
		local paddleLowerBound = gameState.rightPaddle.y + gameState.paddleHeight

		local isBallAboveSegment = ballLowerBound < paddleUpperBound
		local isBallUnderSegment = ballUpperBound > paddleLowerBound

		if isBallAboveSegment then
			self:handleBallAbovePaddle(gameState)
		elseif isBallUnderSegment then
			self:handleBallUnderPaddle(gameState)
		end
	end
end

function opponent:setStatus(isEnabled)
	self.isEnabled = isEnabled
end

return opponent