local support = require 'tests.support'

return {
	{
		name = 'match simulation loads and advances without love graphics',
		run = function()
			support.newGame()
			local originalLove = love
			local originalMatch = package.loaded['match']
			package.loaded['match'] = nil
			love = nil

			local ok, message = pcall(function()
				local match = require 'match'
				match:handleFullscreen()
				match:handleKeypresses('space')
				local startX = match.ball.x
				match:advanceFrame()
				assert(match.ball.x > startX, 'ball should advance without a graphics context')
			end)

			love = originalLove
			package.loaded['match'] = originalMatch
			assert(ok, message)
		end
	},
	{
		name = 'screen renders match scores without owning the score state',
		run = function()
			local fixture = support.newGame()
			fixture.game.scores.left.score = 3
			fixture.game.scores.right.score = 2
			fixture.game.lastLoss = 'right'

			fixture.gameScreen:render()

			assert(fixture.gameScreen.scores.left.value:getText() == 'L2 W3')
			assert(fixture.gameScreen.scores.right.value:getText() == 'L3 W2')
			assert(fixture.game.scores.left.score == 3 and fixture.game.scores.right.score == 2)
		end
	}
}
