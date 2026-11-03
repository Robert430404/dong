local support = require 'tests.support'

return {
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
	}
}
