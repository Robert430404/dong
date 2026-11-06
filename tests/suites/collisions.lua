local support = require 'tests.support'

return {
	{
		name = 'one-player difficulty caps ball speed after paddle hits',
		run = function()
			local presets = {
				{ name = 'easy', factor = 0.65 },
				{ name = 'normal', factor = 0.85 },
				{ name = 'hard', factor = 1.00 }
			}

			for _, preset in ipairs(presets) do
				local fixture = support.newGame()
				local game = fixture.game
				fixture.opponent:setDifficulty(preset.name)
				fixture.opponent:setStatus(true)
				local entry = game.balls[1]
				entry.ball.y = game.leftPaddle.y + game.paddleHeight - entry.ball.height / 2
				entry.velocity.x = -entry.ball.maxXVelocity

				fixture.ballPhysics:handleBallAngle(game, game.leftPaddle, 'left', entry)
				support.near(entry.velocity.x, entry.ball.maxXVelocity * preset.factor)
				support.near(entry.velocity.y, entry.ball.maxXVelocity * preset.factor * 0.75)
			end
		end
	},
	{
		name = 'two-player ball speed is not affected by selected difficulty',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			fixture.opponent:setDifficulty('easy')
			fixture.opponent:setStatus(false)
			local entry = game.balls[1]
			entry.velocity.x = -entry.ball.maxXVelocity

			fixture.ballPhysics:handleBallAngle(game, game.leftPaddle, 'left', entry)
			support.near(entry.velocity.x, entry.ball.maxXVelocity)
		end
	},
	{
		name = 'ceiling reflects the ball once',
		run = function()
			local game = support.newGame().game
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 500, game.upperBoundary + 1
			game.ballVelocity.x, game.ballVelocity.y = 8, -4

			game:advanceFrame()
			support.near(game.ball.y, game.upperBoundary + 3)
			assert(game.ballVelocity.y == 4, 'wall should reflect once')
		end
	},
	{
		name = 'left paddle reflects a center hit to the right',
		run = function()
			local game = support.newGame().game
			game.ball.isMoving = true
			game.ball.x = game.leftPaddle.x + game.paddleWidth + 2
			game.ball.y = game.leftPaddle.y + game.paddleHeight / 2 - game.ball.height / 2
			game.ballVelocity.x, game.ballVelocity.y = -8, 0

			game:advanceFrame()
			assert(game.ballVelocity.x > 0, 'left paddle must reflect right')
			support.near(game.ballVelocity.y, 0)
		end
	},
	{
		name = 'right paddle reflects a high-speed hit',
		run = function()
			local game = support.newGame().game
			game.ball.isMoving = true
			game.ball.x = game.rightPaddle.x - game.ball.width - 2
			game.ball.y = game.rightPaddle.y + game.paddleHeight / 2 - game.ball.height / 2
			game.ballVelocity.x, game.ballVelocity.y = 30, 0

			game:advanceFrame()
			assert(game.ballVelocity.x < 0, 'right paddle must reflect left')
		end
	},
	{
		name = 'simultaneous wall and paddle contacts both resolve',
		run = function()
			local game = support.newGame().game
			game.ball.isMoving = true
			game.leftPaddle.y = game.upperBoundary
			game.ball.x = game.leftPaddle.x + game.paddleWidth + 4
			game.ball.y = game.upperBoundary + 4
			game.ballVelocity.x, game.ballVelocity.y = -8, -8

			game:advanceFrame()
			assert(game.ballVelocity.x > 0 and game.ballVelocity.y > 0, 'ball must reflect away from both surfaces')
			assert(game.ball.y >= game.upperBoundary, 'ball must remain inside the wall')
		end
	}
}
