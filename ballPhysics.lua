local opponent = require 'opponent'

local ballPhysics = {}

function ballPhysics:findNextCollision(match, remaining, ball, velocity)
	local collisionTime = remaining
	local collisionSide = nil

	local function considerCollision(time, side)
		if time >= 0 and time <= collisionTime then
			collisionTime = time
			collisionSide = side
		end
	end

	if velocity.y < 0 then
		considerCollision((match.upperBoundary - ball.y) / velocity.y, 'wall')
	elseif velocity.y > 0 then
		considerCollision((match.lowerBoundary - ball.height - ball.y) / velocity.y, 'wall')
	end

	if velocity.x < 0 then
		considerCollision((match.leftPaddle.x + match.paddleWidth - ball.x) / velocity.x, 'left')
	elseif velocity.x > 0 then
		considerCollision((match.rightPaddle.x - ball.width - ball.x) / velocity.x, 'right')
	end

	local item, itemTime = match.powerUps:findCollision(ball, velocity, remaining)
	if item and itemTime <= collisionTime then
		return itemTime, 'powerUp', item
	end

	return collisionTime, collisionSide
end

function ballPhysics:advance(match, entry)
	local ball = entry.ball
	local velocity = entry.velocity
	local remaining = 1

	while remaining > 0 and ball.isMoving do
		local collisionTime, collisionSide, item = self:findNextCollision(match, remaining, ball, velocity)
		ball.x = ball.x + velocity.x * collisionTime
		ball.y = ball.y + velocity.y * collisionTime
		remaining = remaining - collisionTime

		if collisionSide == 'wall' then
			velocity.y = -velocity.y
		elseif collisionSide == 'powerUp' then
			match.powerUps:activate(item, match, entry)
		elseif collisionSide then
			local paddle = match.rightPaddle
			if collisionSide == 'left' then
				paddle = match.leftPaddle
			end

			if ball.y > paddle.y + match.paddleHeight or ball.y + ball.height < paddle.y then
				match:handleLoss(collisionSide, entry)
			else
				self:handleBallAngle(match, paddle, collisionSide, entry)
			end
		else
			break
		end
	end
end

function ballPhysics:handleBallAngle(match, paddle, side, entry)
	local ball = entry.ball
	ball.isOpeningServe = false
	local velocity = entry.velocity
	local ballCenter = ball.y + ball.height / 2
	local paddleCenter = paddle.y + match.paddleHeight / 2
	local relativePosition = (ballCenter - paddleCenter) / (match.paddleHeight / 2)
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

return ballPhysics
