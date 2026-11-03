local support = require 'tests.support'

return {
	{
		name = '120 Hz updates produce 60 simulation steps',
		run = function()
			local fixture = support.newGame()
			local steps = 0
			fixture.renderer.advanceFrame = function()
				steps = steps + 1
			end

			for i = 1, 120 do
				love.update(1 / 120)
			end

			assert(steps == 60, 'simulation steps: ' .. steps)
		end
	},
	{
		name = '30 Hz updates produce 60 simulation steps',
		run = function()
			local fixture = support.newGame()
			local steps = 0
			fixture.renderer.advanceFrame = function()
				steps = steps + 1
			end

			for i = 1, 30 do
				love.update(1 / 30)
			end

			assert(steps == 60, 'simulation steps: ' .. steps)
		end
	}
}
