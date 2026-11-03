local support = require 'tests.support'

return {
	{
		name = 'resizing preserves a rally and scales positions',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			fixture.renderer.currentScreen = 'game'
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 400, 300
			game.ballVelocity.x, game.ballVelocity.y = 8, -4
			game.leftPaddle.y, game.rightPaddle.y = 200, 300
			game.scores.left.score = 2
			fixture:setScreenSize(960, 360)

			love.resize()

			support.near(game.ball.x, 300)
			support.near(game.ball.y, 150)
			support.near(game.leftPaddle.y, 100)
			support.near(game.rightPaddle.y, 150)
			assert(game.ball.isMoving and game.ballVelocity.x == 8 and game.ballVelocity.y == -4)
			assert(game.scores.left.score == 2, 'resizing must not reset scores')
		end
	},
	{
		name = 'resizing clamps positions and resets the opponent target',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			fixture.renderer.currentScreen = 'game'
			fixture.opponent:setStatus(true)
			fixture.opponent.targetY = 300
			fixture.opponent.aimError = 0.5
			game.leftPaddle.y = game.maxVerticalOffset
			game.ball.x = game.rightPaddle.x - game.ball.width
			game.ball.y = game.lowerBoundary - game.ball.height
			fixture:setScreenSize(960, 360)

			love.resize()

			assert(game.leftPaddle.y <= game.maxVerticalOffset)
			assert(game.ball.x <= game.rightPaddle.x - game.ball.width)
			assert(game.ball.y <= game.lowerBoundary - game.ball.height)
			assert(fixture.opponent.targetY == nil and fixture.opponent.aimError == nil)
		end
	}
}
