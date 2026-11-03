local support = require 'tests.support'

return {
	{
		name = 'resizing changes the viewport without changing a rally',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			fixture.renderer.currentScreen = 'game'
			fixture.renderer.render = function() end
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 400, 300
			game.ballVelocity.x, game.ballVelocity.y = 8, -4
			game.leftPaddle.y, game.rightPaddle.y = 200, 300
			game.scores.left.score = 2
			fixture.opponent.targetY = 300
			fixture.opponent.aimError = 0.5
			fixture:setScreenSize(960, 360)

			love.draw()

			local transform = fixture:getTransform()
			support.near(transform.scale, 0.5)
			support.near(transform.x, 160)
			support.near(transform.y, 0)
			support.near(game.ball.x, 400)
			support.near(game.ball.y, 300)
			support.near(game.leftPaddle.y, 200)
			support.near(game.rightPaddle.y, 300)
			assert(game.ball.isMoving and game.ballVelocity.x == 8 and game.ballVelocity.y == -4)
			assert(game.scores.left.score == 2, 'resizing must not reset scores')
			assert(fixture.opponent.targetY == 300 and fixture.opponent.aimError == 0.5)
		end
	},
	{
		name = 'a tall window centers the playfield vertically',
		run = function()
			local fixture = support.newGame()
			fixture.renderer.render = function() end
			fixture:setScreenSize(640, 720)

			love.draw()

			local transform = fixture:getTransform()
			support.near(transform.scale, 0.5)
			support.near(transform.x, 0)
			support.near(transform.y, 180)
		end
	},
	{
		name = 'window size does not change ball movement',
		run = function()
			local first = support.newGame()
			first.game.ball.isMoving = true
			first.game.ball.x, first.game.ball.y = 400, 300
			first.game.ballVelocity.x, first.game.ballVelocity.y = 8, -4
			first.game:advanceFrame()
			local expectedX, expectedY = first.game.ball.x, first.game.ball.y

			local second = support.newGame()
			second:setScreenSize(960, 360)
			second.game.ball.isMoving = true
			second.game.ball.x, second.game.ball.y = 400, 300
			second.game.ballVelocity.x, second.game.ballVelocity.y = 8, -4
			second.game:advanceFrame()

			support.near(second.game.ball.x, expectedX)
			support.near(second.game.ball.y, expectedY)
		end
	},
	{
		name = 'fullscreen toggle does not change rally state',
		run = function()
			local fixture = support.newGame()
			fixture.renderer.currentScreen = 'game'
			fixture.game.ball.x = 400
			fixture.opponent.targetY = 300

			love.keypressed('f11', 'f11', false)

			support.near(fixture.game.ball.x, 400)
			assert(fixture.opponent.targetY == 300, 'fullscreen must not reset the opponent')
		end
	}
}
