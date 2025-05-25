local opponent = {
	isEnabled = false
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
		local newPaddleY = gameState.rightPaddle.y - gameState.paddleVelocity
		if newPaddleY < 8 then
			gameState.rightPaddle.y = gameState.offsetGap
		else
			gameState.rightPaddle.y = newPaddleY
		end
	elseif isBallUnderPaddle then
		gameState.rightPaddle.y = gameState.rightPaddle.y + gameState.paddleVelocity
	else
		gameState.rightPaddle.y = gameState.rightPaddle.y
	end
end

function opponent:setStatus(isEnabled)
	self.isEnabled = isEnabled
end

return opponent