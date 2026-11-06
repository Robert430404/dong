local support = require 'tests.support'

return {
	{
		name = 'font density follows viewport scale without rebuilding every frame',
		run = function()
			local fixture = support.newGame()
			fixture.renderer.render = function() end
			fixture:setScreenSize(1920, 1080)

			love.draw()
			local fonts = fixture:getFonts()
			assert(fixture.renderer.fontScale == 1.5)
			assert(#fonts == 10, 'five fonts should be rebuilt at the new density')
			for index = 6, 10 do
				support.near(fonts[index].density, 1.5)
			end

			love.draw()
			assert(#fonts == 10, 'unchanged scale must reuse fonts')
			fixture:setScreenSize(1280, 720)
			love.draw()
			assert(fixture.renderer.fontScale == 1 and #fonts == 15)
		end
	},
	{
		name = 'font density includes display DPI and rounds up',
		run = function()
			local fixture = support.newGame()
			fixture.renderer.render = function() end
			fixture:setScreenSize(1600, 900)
			fixture:setDPIScale(1.5)

			love.draw()

			support.near(fixture.renderer.fontScale, 2)
			local fonts = fixture:getFonts()
			support.near(fonts[#fonts].density, 2)
		end
	},
	{
		name = 'font refresh preserves score and rally state',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			fixture.renderer.currentScreen = 'game'
			fixture.renderer.render = function() end
			game.scores.left.score = 7
			game.scores.left.value:set('L0 W7')
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 400, 300
			game.ballVelocity.x, game.ballVelocity.y = 8, -4
			fixture.opponent.targetY = 240
			fixture:setScreenSize(1920, 1080)

			love.draw()

			assert(game.scores.left.value:getText() == 'L0 W7' and game.scores.left.score == 7)
			assert(game.ball.isMoving and game.ball.x == 400 and game.ball.y == 300)
			assert(game.ballVelocity.x == 8 and game.ballVelocity.y == -4)
			assert(fixture.opponent.targetY == 240)
			support.near(game.scores.left.x, 270)
		end
	}
}
