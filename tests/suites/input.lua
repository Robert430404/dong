local support = require 'tests.support'

return {
	{
		name = 'startup disables text input',
		run = function()
			local fixture = support.newGame()
			assert(fixture.textInput == false, 'game must disable text input on startup')
		end
	},
	{
		name = 'held keys move the left paddle and opposing keys cancel',
		run = function()
			local game = support.newGame().game
			local startY = game.leftPaddle.y

			game:handleHeldkey(function(key) return key == 'w' end)
			support.near(game.leftPaddle.y, startY - game.paddleVelocity)
			game:handleHeldkey(function(key) return key == 's' end)
			support.near(game.leftPaddle.y, startY)
			game:handleHeldkey(function(key) return key == 'w' or key == 's' end)
			support.near(game.leftPaddle.y, startY)
		end
	},
	{
		name = 'brief left paddle press is consumed once',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local startY = game.leftPaddle.y
			fixture.renderer.currentScreen = 'game'

			love.keypressed('s', 's', false)
			game:handleHeldkey(support.noKeysDown)
			support.near(game.leftPaddle.y, startY + game.paddleVelocity)
			game:handleHeldkey(support.noKeysDown)
			support.near(game.leftPaddle.y, startY + game.paddleVelocity)
		end
	},
	{
		name = 'buffered held key does not move twice',
		run = function()
			local game = support.newGame().game
			local startY = game.leftPaddle.y

			game:handleKeypresses('w', 'w', false)
			game:handleHeldkey(function(key) return key == 'w' end)
			support.near(game.leftPaddle.y, startY - game.paddleVelocity)
		end
	},
	{
		name = 'brief right paddle press moves in two-player mode',
		run = function()
			local game = support.newGame().game
			local startY = game.rightPaddle.y

			game:handleKeypresses('down', 'down', false)
			game:handleHeldkey(support.noKeysDown)
			support.near(game.rightPaddle.y, startY + game.paddleVelocity)
		end
	},
	{
		name = 'key repeat does not buffer extra movement',
		run = function()
			local game = support.newGame().game
			local startY = game.leftPaddle.y

			game:handleKeypresses('s', 's', true)
			game:handleHeldkey(support.noKeysDown)
			support.near(game.leftPaddle.y, startY)
		end
	},
	{
		name = 'one-player mode discards right paddle input',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			local startY = game.rightPaddle.y
			fixture.opponent:setStatus(true)

			game:handleKeypresses('up', 'up', false)
			game:handleHeldkey(support.noKeysDown)
			support.near(game.rightPaddle.y, startY)
			fixture.opponent:setStatus(false)
			game:handleHeldkey(support.noKeysDown)
			support.near(game.rightPaddle.y, startY)
		end
	}
}
