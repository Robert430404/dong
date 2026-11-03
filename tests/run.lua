-- Minimal LÖVE stubs let the simulation run without a window.
love = {
	graphics = {
		getWidth = function() return 1280 end,
		getHeight = function() return 720 end,
		newFont = function() return {} end,
		newText = function()
			return { getWidth = function() return 100 end, getHeight = function() return 40 end, set = function() end }
		end
	},
	keyboard = { isDown = function() return false end },
	window = {}, event = {}
}

require 'main'
local renderer = require 'screens.renderer'
local game = require 'screens.gameScreen'
local opponent = require 'opponent'

local function near(actual, expected)
	assert(math.abs(actual - expected) < 0.00001, actual .. ' ~= ' .. expected)
end

-- Equal elapsed time produces equal simulation counts at different render rates.
local steps = 0
local originalAdvance = renderer.advanceFrame
renderer.advanceFrame = function() steps = steps + 1 end
for i = 1, 120 do love.update(1 / 120) end
assert(steps == 60, '120 Hz update count: ' .. steps)
steps = 0
for i = 1, 30 do love.update(1 / 30) end
assert(steps == 60, '30 Hz update count: ' .. steps)
renderer.advanceFrame = originalAdvance

game:handleFullscreen()
game.ball.isMoving = true
game.ball.x, game.ball.y = 500, game.upperBoundary + 1
game.ballVelocity.x, game.ballVelocity.y = 8, -4
game:advanceFrame()
near(game.ball.y, game.upperBoundary + 3)
assert(game.ballVelocity.y == 4, 'wall should reflect once')

game.ball.x = game.leftPaddle.x + game.paddleWidth + 2
game.ball.y = game.leftPaddle.y + game.paddleHeight / 2 - game.ball.height / 2
game.ballVelocity.x, game.ballVelocity.y = -8, 0
game:advanceFrame()
assert(game.ballVelocity.x > 0, 'left paddle must reflect right')
near(game.ballVelocity.y, 0)

game.ball.x = game.rightPaddle.x - game.ball.width - 2
game.ball.y = game.rightPaddle.y + game.paddleHeight / 2 - game.ball.height / 2
game.ballVelocity.x, game.ballVelocity.y = 30, 0
game:advanceFrame()
assert(game.ballVelocity.x < 0, 'right paddle must reflect left even at high speed')

local oldScore = game.scores.right.score
game.ball.x = game.leftPaddle.x + game.paddleWidth + 2
game.ball.y = game.upperBoundary
game.ballVelocity.x, game.ballVelocity.y = -8, 0
game:advanceFrame()
assert(game.scores.right.score == oldScore + 1 and not game.ball.isMoving, 'miss should score once')
game:advanceFrame()
assert(game.scores.right.score == oldScore + 1, 'stopped ball must not score again')
game:handleKeypresses('space')
assert(game.ballVelocity.x < 0, 'serve should travel toward the player who missed')

opponent:setStatus(true)
game.ball.x, game.ball.y = 500, 200
game.ballVelocity.x, game.ballVelocity.y = 8, 3
local beforeX, beforeY = game.ball.x, game.ball.y
opponent:run(game)
assert(game.ball.x == beforeX and game.ball.y == beforeY, 'opponent must not move the ball')
assert(opponent.targetY and opponent.targetY >= game.offsetGap and opponent.targetY <= game.maxVerticalOffset)
opponent:setStatus(false)

print('All regression checks passed.')
