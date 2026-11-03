local support = require 'tests.support'

local function hasText(lines, expected)
	for _, line in ipairs(lines) do
		if line == expected then
			return true
		end
	end

	return false
end

return {
	{
		name = 'one-player menu shows the default normal difficulty',
		run = function()
			local fixture = support.newGame()
			love.keypressed('left', 'left', false)
			fixture.renderer:render()

			assert(fixture.opponent.isEnabled and fixture.opponent.difficulty == 'normal')
			assert(hasText(fixture:getDrawnText(), '[UP/DOWN] DIFFICULTY: NORMAL'))
		end
	},
	{
		name = 'difficulty controls select and clamp the presets',
		run = function()
			local fixture = support.newGame()
			local opponent = fixture.opponent
			love.keypressed('left', 'left', false)
			love.keypressed('up', 'up', false)
			love.keypressed('up', 'up', false)
			assert(opponent.difficulty == 'easy')
			assert(opponent.reactionSteps == 30 and opponent.speedFactor == 0.40 and opponent.errorFraction == 1.00)

			love.keypressed('down', 'down', false)
			assert(opponent.difficulty == 'normal')
			assert(opponent.reactionSteps == 21 and opponent.speedFactor == 0.65 and opponent.errorFraction == 0.50)

			love.keypressed('down', 'down', false)
			love.keypressed('down', 'down', false)
			assert(opponent.difficulty == 'hard')
			assert(opponent.reactionSteps == 9 and opponent.speedFactor == 0.85 and opponent.errorFraction == 0.12)
			fixture.renderer:render()
			assert(hasText(fixture:getDrawnText(), '[UP/DOWN] DIFFICULTY: HARD'))
		end
	},
	{
		name = 'two-player mode hides and ignores difficulty controls',
		run = function()
			local fixture = support.newGame()
			love.keypressed('down', 'down', false)
			fixture.renderer:render()

			assert(not fixture.opponent.isEnabled and fixture.opponent.difficulty == 'normal')
			assert(not hasText(fixture:getDrawnText(), '[UP/DOWN] DIFFICULTY: NORMAL'))
		end
	},
	{
		name = 'selected difficulty remains active when starting the game',
		run = function()
			local fixture = support.newGame()
			love.keypressed('left', 'left', false)
			love.keypressed('up', 'up', false)
			love.keypressed('right', 'right', false)
			love.keypressed('down', 'down', false)
			love.keypressed('left', 'left', false)
			love.keypressed('return', 'return', false)

			assert(fixture.renderer.currentScreen == 'game')
			assert(fixture.opponent.isEnabled and fixture.opponent.difficulty == 'easy')
		end
	},
	{
		name = 'invalid difficulty does not change the opponent',
		run = function()
			local opponent = support.newGame().opponent
			assert(opponent:setDifficulty('unknown') == false)
			assert(opponent.difficulty == 'normal' and opponent.reactionSteps == 21)
		end
	}
}
