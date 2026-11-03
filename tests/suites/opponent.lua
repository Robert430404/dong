local support = require 'tests.support'

local function playStraightApproach(difficulty)
	local fixture = support.newGame()
	local game = fixture.game
	local opponent = fixture.opponent
	opponent:setDifficulty(difficulty)
	opponent:setStatus(true)
	opponent.random = function() return 0.95 end
	game.ball.isMoving = true
	game.ball.x = game.rightPaddle.x - game.ball.width - 800
	game.ball.y = 360
	game.ballVelocity.x, game.ballVelocity.y = 8, 0

	for i = 1, 100 do
		game:advanceFrame()
	end

	return game
end

return {
	{
		name = 'easy can miss a reachable straight shot',
		run = function()
			local game = playStraightApproach('easy')
			assert(game.scores.left.score == 1, 'easy opponent should miss with a large aim error')
		end
	},
	{
		name = 'hard returns the same straight shot',
		run = function()
			local game = playStraightApproach('hard')
			assert(game.scores.left.score == 0 and game.ballVelocity.x < 0, 'hard opponent should return the shot')
		end
	},
	{
		name = 'opponent chooses a bounded target without moving the ball',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local opponent = fixture.opponent
			opponent:setStatus(true)
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 500, 200
			game.ballVelocity.x, game.ballVelocity.y = 8, 3
			local beforeX, beforeY = game.ball.x, game.ball.y

			opponent:run(game)
			assert(game.ball.x == beforeX and game.ball.y == beforeY, 'opponent must not move the ball')
			assert(opponent.targetY and opponent.targetY >= game.offsetGap and opponent.targetY <= game.maxVerticalOffset)
		end
	},
	{
		name = 'prediction accounts for a wall bounce',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local opponent = fixture.opponent
			opponent:setStatus(true)
			opponent.errorFraction = 0
			game.ball.isMoving = true
			game.ball.x = game.rightPaddle.x - game.ball.width - 1000
			game.ball.y = game.upperBoundary + 100
			game.ballVelocity.x, game.ballVelocity.y = 10, -4

			opponent:run(game)
			local expected = game.upperBoundary + 300 + game.ball.height / 2 - game.paddleHeight / 2
			support.near(opponent.targetY, expected)
		end
	},
	{
		name = 'opponent reacts at the configured interval',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local opponent = fixture.opponent
			opponent:setStatus(true)
			opponent.errorFraction = 0
			opponent.reactionSteps = 3
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 500, 200
			game.ballVelocity.x, game.ballVelocity.y = 8, 0

			opponent:run(game)
			local firstTarget = opponent.targetY
			game.ball.y = 400
			opponent:run(game)
			opponent:run(game)
			support.near(opponent.targetY, firstTarget)
			opponent:run(game)
			assert(opponent.targetY ~= firstTarget, 'target should update after the reaction interval')
		end
	},
	{
		name = 'aim error stays stable until the next approach',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local opponent = fixture.opponent
			local rolls = 0
			opponent.random = function()
				rolls = rolls + 1
				return 0.75
			end
			opponent:setStatus(true)
			opponent.reactionSteps = 1
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 500, 200
			game.ballVelocity.x, game.ballVelocity.y = 8, 0

			opponent:run(game)
			local firstTarget = opponent.targetY
			opponent:run(game)
			support.near(opponent.targetY, firstTarget)
			assert(rolls == 1, 'aim error should not change during an approach')

			game.ballVelocity.x = -8
			opponent:run(game)
			game.ballVelocity.x = 8
			opponent:run(game)
			assert(rolls == 2, 'next approach should choose a new error')
		end
	},
	{
		name = 'opponent movement is speed limited and clamped',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local opponent = fixture.opponent
			opponent:setStatus(true)
			opponent.errorFraction = 0
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 500, game.upperBoundary
			game.ballVelocity.x, game.ballVelocity.y = 8, 0
			local startY = game.rightPaddle.y

			opponent:run(game)
			support.near(game.rightPaddle.y, startY - game.paddleVelocity * opponent.speedFactor)
			for i = 1, 100 do
				opponent:run(game)
			end
			assert(game.rightPaddle.y >= game.offsetGap, 'paddle must remain within its upper bound')
		end
	}
}
