local layout = require 'powerups.layout'

local splitBall = {
	id = 'split-ball'
}

function splitBall:create(screenWidth, screenHeight)
	return layout:create(screenWidth, screenHeight)
end

function splitBall:draw(item)
	local centerX = item.x + item.width / 2
	local centerY = item.y + item.height / 2

	love.graphics.setColor( love.math.colorFromBytes(110, 170, 255) )
	love.graphics.rectangle( "line", item.x, item.y, item.width, item.height )
	love.graphics.rectangle( "fill", centerX - 9, centerY - 13, 6, 6 )
	love.graphics.rectangle( "fill", centerX + 3, centerY + 7, 6, 6 )
end

function splitBall:apply(gameState, entry)
	local newBall = {}
	for key, value in pairs(entry.ball) do
		newBall[key] = value
	end

	local newVelocity = { x = -entry.velocity.x, y = -entry.velocity.y }
	gameState:addBall(newBall, newVelocity, entry.speedBoost)
end

return splitBall
