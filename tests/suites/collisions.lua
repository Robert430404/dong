local support = require 'tests.support'

return {
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
