local support = require 'tests.support'

local function missLeftPaddle(game)
	game.ball.isMoving = true
	game.ball.x = game.leftPaddle.x + game.paddleWidth + 2
	game.ball.y = game.upperBoundary
	game.ballVelocity.x, game.ballVelocity.y = -8, 0
	game:advanceFrame()
end

return {
	{
		name = 'a miss scores only once',
		run = function()
			local game = support.newGame().game
			missLeftPaddle(game)

			assert(game.scores.right.score == 1 and not game.ball.isMoving, 'miss should score once')
			game:advanceFrame()
			assert(game.scores.right.score == 1, 'stopped ball must not score again')
		end
	},
	{
		name = 'serve travels toward the player who missed',
		run = function()
			local game = support.newGame().game
			missLeftPaddle(game)

			game:handleKeypresses('space')
			assert(game.ballVelocity.x < 0, 'serve should travel toward the left player')
		end
	}
}
