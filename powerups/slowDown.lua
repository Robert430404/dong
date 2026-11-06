local layout = require 'powerups.layout'

local slowDown = {
	id = 'slow-down'
}

function slowDown:create(screenWidth, screenHeight)
	return layout:create(screenWidth, screenHeight)
end

function slowDown:draw(item)
	local centerX = item.x + item.width / 2
	local centerY = item.y + item.height / 2

	love.graphics.setColor( love.math.colorFromBytes(190, 100, 235) )
	love.graphics.rectangle( "line", item.x, item.y, item.width, item.height )
	love.graphics.rectangle( "fill", centerX - 8, centerY - 11, 5, 22 )
	love.graphics.rectangle( "fill", centerX + 3, centerY - 11, 5, 22 )
end

function slowDown:apply(gameState, entry)
	local velocity = entry.velocity
	local speed = math.sqrt(velocity.x * velocity.x + velocity.y * velocity.y)
	if speed == 0 then
		return
	end

	local factor = entry.ball.initialVelocity / speed
	velocity.x = velocity.x * factor
	velocity.y = velocity.y * factor
	entry.speedBoost = nil
end

return slowDown
