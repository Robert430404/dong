local support = require 'tests.support'

local function hitItem(game)
	local item = game.powerUps:spawn('split-ball', 1280, 720)
	game.ball.isMoving = true
	game.ball.x = item.x - game.ball.width - 4
	game.ball.y = item.y + 4
	game.ballVelocity.x, game.ballVelocity.y = 8, 0
	game:advanceFrame()
end

return {
	{
		name = 'power-up icons are centered within their boxes',
		run = function()
			local ids = { 'split-ball', 'slow-down', 'speed-shift' }
			for _, id in ipairs(ids) do
				local fixture = support.newGame()
				local definition = require('powerups.registry'):get(id)
				local item = { x = 100, y = 200, width = 40, height = 60 }
				definition:draw(item)

				local minX, minY = math.huge, math.huge
				local maxX, maxY = -math.huge, -math.huge
				for _, shape in ipairs(fixture:getShapes()) do
					if shape.mode == 'fill' then
						minX = math.min(minX, shape.x)
						maxX = math.max(maxX, shape.x + shape.width)
						minY = math.min(minY, shape.y)
						maxY = math.max(maxY, shape.y + shape.height)
					elseif shape.mode == 'polyline' then
						for index = 1, #shape.points, 2 do
							minX = math.min(minX, shape.points[index])
							maxX = math.max(maxX, shape.points[index])
							minY = math.min(minY, shape.points[index + 1])
							maxY = math.max(maxY, shape.points[index + 1])
						end
						assert(shape.points[3] < shape.points[1] and shape.points[3] < shape.points[5], 'speed-shift icon must point left')
					end
				end

				support.near((minX + maxX) / 2, item.x + item.width / 2)
				support.near((minY + maxY) / 2, item.y + item.height / 2)
			end
		end
	},
	{
		name = 'speed-shift rotates and boosts a horizontal ball in either direction',
		run = function()
			for direction = 0, 1 do
				local game = support.newGame().game
				local speedShift = require 'powerups.speedShift'
				speedShift.random = function() return direction end
				local item = game.powerUps:spawn('speed-shift', 1280, 720)
				game.ball.isMoving = true
				game.ball.x = item.x - game.ball.width - 4
				game.ball.y = item.y + 5
				game.ballVelocity.x, game.ballVelocity.y = 8, 0

				game:advanceFrame()

				local sign = direction == 0 and -1 or 1
				support.near(game.ballVelocity.x, 8 * 1.3 * math.cos(math.rad(13.5)))
				support.near(game.ballVelocity.y, sign * 8 * 1.3 * math.sin(math.rad(13.5)))
				support.near(game.balls[1].speedBoost, 1.3)
				assert(#game.powerUps.active == 0)
			end
		end
	},
	{
		name = 'speed boost lasts through walls but ends at a paddle',
		run = function()
			local game = support.newGame().game
			local entry = game.balls[1]
			local speedShift = require 'powerups.speedShift'
			speedShift.random = function() return 0 end
			entry.ball.isMoving = true
			entry.ball.x, entry.ball.y = 500, game.upperBoundary + 1
			entry.velocity.x, entry.velocity.y = 8, 0
			speedShift:apply(game, entry)

			game:advanceFrame()
			assert(entry.velocity.y > 0 and entry.speedBoost == 1.3, 'wall must not remove boost')
			local baseXVelocity = math.abs(entry.velocity.x) / entry.speedBoost
			entry.ball.x = game.leftPaddle.x + game.paddleWidth + 1
			entry.ball.y = game.leftPaddle.y + game.paddleHeight / 2 - entry.ball.height / 2
			entry.velocity.x = -math.abs(entry.velocity.x)
			entry.velocity.y = 0
			game:advanceFrame()
			assert(entry.speedBoost == nil, 'paddle must remove boost')
			support.near(entry.velocity.x, baseXVelocity + entry.ball.velocityCompoundFactor)
		end
	},
	{
		name = 'split balls inherit a boost and slow-down clears it',
		run = function()
			local game = support.newGame().game
			local entry = game.balls[1]
			entry.ball.isMoving = true
			entry.velocity.x, entry.velocity.y = 8, 0
			local speedShift = require 'powerups.speedShift'
			speedShift.random = function() return 1 end
			speedShift:apply(game, entry)
			local splitBall = require 'powerups.splitBall'
			splitBall:apply(game, entry)
			local second = game.balls[2]
			support.near(second.speedBoost, entry.speedBoost)

			local slowDown = require 'powerups.slowDown'
			slowDown:apply(game, second)
			assert(second.speedBoost == nil and entry.speedBoost == 1.3)
			support.near(math.sqrt(second.velocity.x ^ 2 + second.velocity.y ^ 2), second.ball.initialVelocity)
		end
	},
	{
		name = 'split-ball item includes the expanded vertical edge',
		run = function()
			local game = support.newGame().game
			local item = game.powerUps:spawn('split-ball', 1280, 720)
			assert(item.width == 32 and item.height == 48)
			game.ball.isMoving = true
			game.ball.x = item.x - game.ball.width - 4
			game.ball.y = item.y - game.ball.height + 1
			game.ballVelocity.x, game.ballVelocity.y = 8, 0

			game:advanceFrame()
			assert(#game.balls == 2, 'ball should activate the enlarged edge')
		end
	},
	{
		name = 'power-up delay runs only during an active rally',
		run = function()
			local game = support.newGame().game
			local manager = game.powerUps
			manager.random = function(minimum, maximum)
				if minimum == 180 and maximum == 360 then
					return 2
				end
				assert(minimum == 1 and maximum >= 1 and maximum <= 3)
				return 1
			end
			manager:reset(60)

			for i = 1, 10 do
				game:advanceFrame()
			end
			assert(manager.stepsUntilSpawn == 2 and #manager.active == 0)
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 400, 300
			game.ballVelocity.x, game.ballVelocity.y = 0, 0
			game:advanceFrame()
			assert(#manager.active == 0)
			game:advanceFrame()
			assert(#manager.active == 1 and #manager.remainingIds == 2)
			for i = 1, 10 do
				game:advanceFrame()
			end
			assert(#manager.active == 1 and manager.stepsUntilSpawn == 2, 'next delay must wait for collection')
			local first = manager.active[1]
			assert(manager:activate(first, game, game.balls[1]))
			game:advanceFrame()
			assert(#manager.active == 0, 'second power-up must wait for its delay')
			game:advanceFrame()
			assert(#manager.active == 1 and manager.active[1].id ~= first.id)
			local second = manager.active[1]
			assert(manager:activate(second, game, game.balls[1]))
			game:advanceFrame()
			assert(#manager.active == 0)
			game:advanceFrame()
			assert(#manager.active == 1 and manager.active[1].id ~= first.id and manager.active[1].id ~= second.id)
			assert(#manager.remainingIds == 0, 'each type should spawn only once')
			assert(manager:activate(manager.active[1], game, game.balls[1]))
			for i = 1, 10 do
				game:advanceFrame()
			end
			assert(#manager.active == 0, 'power-ups must not respawn within the rally')
		end
	},
	{
		name = 'slow-down resets only the striking ball and preserves its direction',
		run = function()
			local game = support.newGame().game
			local item = game.powerUps:spawn('slow-down', 1280, 720)
			game.ball.isMoving = true
			game.ball.x = item.x - game.ball.width - 4
			game.ball.y = item.y + 5
			game.ballVelocity.x, game.ballVelocity.y = 16, 12
			local otherBall = { x = 400, y = 200, width = game.ball.width, height = game.ball.height, isMoving = true }
			local otherVelocity = { x = -10, y = 0 }
			game:addBall(otherBall, otherVelocity)

			game:advanceFrame()

			assert(#game.powerUps.active == 0 and #game.balls == 2)
			support.near(game.ballVelocity.x, 6.4)
			support.near(game.ballVelocity.y, 4.8)
			support.near(otherVelocity.x, -10)
		end
	},
	{
		name = 'registered slow-down can be selected for a timed spawn',
		run = function()
			local game = support.newGame().game
			local manager = game.powerUps
			manager.stepsUntilSpawn = 1
			manager.random = function(minimum, maximum)
				if minimum == 1 then
					assert(maximum == 3)
					return 2
				end
				return minimum
			end
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 400, 300
			game.ballVelocity.x, game.ballVelocity.y = 0, 0

			game:advanceFrame()
			assert(#manager.active == 1 and manager.active[1].id == 'slow-down')
		end
	},
	{
		name = 'power-up waits until its spawn location is clear',
		run = function()
			local game = support.newGame().game
			local manager = game.powerUps
			manager.stepsUntilSpawn = 1
			manager.random = function(minimum) return minimum end
			game.ball.isMoving = true
			game.ball.x, game.ball.y = 630, 460
			game.ballVelocity.x, game.ballVelocity.y = 0, 0

			game:advanceFrame()
			assert(#manager.active == 0 and #manager.remainingIds == 3)
			game.ball.x = 400
			game:advanceFrame()
			assert(#manager.active == 1 and #manager.remainingIds == 2)
		end
	},
	{
		name = 'power-up definitions can be registered and retrieved',
		run = function()
			local fixture = support.newGame()
			local registry = require 'powerups.registry'
			local definition = {
				create = function() return { x = 10, y = 10, width = 10, height = 10 } end,
				draw = function() end,
				apply = function() end
			}

			assert(registry:register('test', definition))
			assert(registry:get('test') == definition)
			assert(not registry:register('test', definition), 'duplicate registration must not overwrite')
			assert(not registry:register('invalid', {}), 'incomplete definitions must be rejected')
			assert(fixture.game.powerUps:spawn('test', 1280, 720).id == 'test')
			assert(fixture.game.powerUps:spawn('unknown', 1280, 720) == nil)
		end
	},
	{
		name = 'hitting the item creates two balls moving in opposite directions',
		run = function()
			local game = support.newGame().game
			hitItem(game)

			assert(#game.powerUps.active == 0, 'item must be consumed')
			assert(#game.balls == 2, 'one ball should become two')
			local first = game.balls[1]
			local second = game.balls[2]
			assert(first.ball ~= second.ball and first.velocity ~= second.velocity)
			support.near(first.velocity.x, -second.velocity.x)
			support.near(first.velocity.y, -second.velocity.y)
			game:advanceFrame()
			assert(#game.balls == 2, 'consumed item must not split again')
			assert(first.ball.x > second.ball.x, 'balls must separate')
		end
	},
	{
		name = 'a high-speed ball cannot pass through the item',
		run = function()
			local game = support.newGame().game
			local item = game.powerUps:spawn('split-ball', 1280, 720)
			game.ball.isMoving = true
			game.ball.x = item.x - game.ball.width - 20
			game.ball.y = item.y + 4
			game.ballVelocity.x, game.ballVelocity.y = 80, 0

			game:advanceFrame()
			assert(#game.balls == 2 and #game.powerUps.active == 0)
		end
	},
	{
		name = 'a ball outside the item does not split',
		run = function()
			local game = support.newGame().game
			local item = game.powerUps:spawn('split-ball', 1280, 720)
			game.ball.isMoving = true
			game.ball.x = item.x - game.ball.width - 4
			game.ball.y = item.y - game.ball.height - 1
			game.ballVelocity.x, game.ballVelocity.y = 8, 0

			game:advanceFrame()
			assert(#game.balls == 1 and #game.powerUps.active == 1)
		end
	},
	{
		name = 'a missed ball scores while the other keeps playing',
		run = function()
			local game = support.newGame().game
			hitItem(game)
			local first = game.balls[1]
			local second = game.balls[2]
			first.ball.x = game.leftPaddle.x + game.paddleWidth + 2
			first.ball.y = game.upperBoundary
			first.velocity.x, first.velocity.y = -8, 0
			second.ball.x, second.ball.y = 500, 300
			second.velocity.x, second.velocity.y = 8, 0

			game:advanceFrame()
			assert(game.scores.right.score == 1 and #game.balls == 1)
			assert(game.ball == second.ball and game.ball.isMoving, 'surviving ball must remain in play')
			local x = game.ball.x
			game:handleKeypresses('space')
			game:advanceFrame()
			assert(game.ball.x > x and game.scores.right.score == 1, 'serve must not interrupt a live ball')
		end
	},
	{
		name = 'last miss ends the rally and schedules a new power-up',
		run = function()
			local game = support.newGame().game
			hitItem(game)
			for _, entry in ipairs(game.balls) do
				entry.ball.x = game.leftPaddle.x + game.paddleWidth + 2
				entry.ball.y = game.upperBoundary
				entry.velocity.x, entry.velocity.y = -8, 0
			end

			game:advanceFrame()
			assert(game.scores.right.score == 2, 'each missed ball scores once')
			assert(#game.balls == 1 and not game.ball.isMoving and #game.powerUps.active == 0)
			assert(#game.powerUps.remainingIds == 3 and game.powerUps.stepsUntilSpawn > 0)
			game:handleKeypresses('space')
			assert(game.ball.isMoving and game.ballVelocity.x < 0, 'next serve should be available')
		end
	},
	{
		name = 'opponent targets the earliest incoming ball',
		run = function()
			local fixture = support.newGame()
			local game = fixture.game
			hitItem(game)
			local first = game.balls[1]
			local second = game.balls[2]
			first.ball.x, first.velocity.x = 600, 8
			second.ball.x, second.velocity.x = 900, 8
			fixture.opponent:setStatus(true)

			fixture.opponent:run(game)
			assert(fixture.opponent.trackedBall == second.ball)
		end
	}
}
