local layout = require 'powerups.layout'

local speedShift = {
	id = 'speed-shift',
	random = math.random
}

function speedShift:create(screenWidth, screenHeight)
	return layout:create(screenWidth, screenHeight)
end

function speedShift:draw(item)
	local centerX = item.x + item.width / 2
	local centerY = item.y + item.height / 2

	love.graphics.setColor( love.math.colorFromBytes(255, 170, 60) )
	love.graphics.rectangle( "line", item.x, item.y, item.width, item.height )
	love.graphics.push( "all" )
	love.graphics.setLineWidth( 3 )
	love.graphics.line( centerX + 7, centerY - 10, centerX - 7, centerY, centerX + 7, centerY + 10 )
	love.graphics.pop()
end

function speedShift:apply(gameState, entry)
	local angle = math.rad(13.5)
	if self.random(0, 1) == 0 then
		angle = -angle
	end

	local velocity = entry.velocity
	local cosine = math.cos(angle)
	local sine = math.sin(angle)
	local velocityX = velocity.x * cosine - velocity.y * sine
	local velocityY = velocity.x * sine + velocity.y * cosine

	velocity.x = velocityX * 1.3
	velocity.y = velocityY * 1.3
	entry.speedBoost = (entry.speedBoost or 1) * 1.3
end

return speedShift
