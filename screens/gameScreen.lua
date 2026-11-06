local systemConfig = require 'config.systemConfig'
local match = require 'match'

local scoreFont = love.graphics.newFont( "assets/doto-regular.ttf", 48 )
local gameScreen = {
	scores = {
		left = { value = love.graphics.newText(scoreFont, "L0 W0"), x = 0, y = 0 },
		right = { value = love.graphics.newText(scoreFont, "L0 W0"), x = 0, y = 0 }
	},
	leftScore = 0,
	rightScore = 0
}

function gameScreen:layoutScores()
	local centerLine = systemConfig:getScreenWidth() / 2
	self.scores.left.x = centerLine / 2 - self.scores.left.value:getWidth() / 2
	self.scores.left.y = match.offsetGap
	self.scores.right.x = centerLine + centerLine / 2 - self.scores.right.value:getWidth() / 2
	self.scores.right.y = match.offsetGap
end

function gameScreen:updateFonts(scale)
	scoreFont = love.graphics.newFont( "assets/doto-regular.ttf", 48, "normal", scale )
	self.scores.left.value:setFont(scoreFont)
	self.scores.right.value:setFont(scoreFont)
	self:layoutScores()
end

function gameScreen:updateScores()
	local left = match.scores.left.score
	local right = match.scores.right.score
	if left == self.leftScore and right == self.rightScore then
		return
	end

	self.leftScore = left
	self.rightScore = right
	self.scores.left.value:set( string.format("L%s W%s", right, left) )
	self.scores.right.value:set( string.format("L%s W%s", left, right) )
	self:layoutScores()
end

function gameScreen:render()
	self:updateScores()
	love.graphics.setColor( love.math.colorFromBytes(44, 44, 44) )
	love.graphics.rectangle( "fill", match.divider.x, match.divider.y, match.divider.width, match.divider.height )

	if match.lastLoss ~= 'none' then
		local lastLoss = self.scores[match.lastLoss]
		love.graphics.setColor( love.math.colorFromBytes(99, 22, 22) )
		love.graphics.rectangle( "fill", lastLoss.x - 2, lastLoss.y + lastLoss.value:getHeight(), lastLoss.value:getWidth(), match.offsetGap )
	end

	love.graphics.setColor( love.math.colorFromBytes(122, 122, 122) )
	love.graphics.draw( self.scores.left.value, self.scores.left.x, self.scores.left.y )
	love.graphics.draw( self.scores.right.value, self.scores.right.x, self.scores.right.y )

	love.graphics.setColor( love.math.colorFromBytes(46, 207, 133) )
	love.graphics.rectangle( "fill", match.leftPaddle.x, match.leftPaddle.y, match.paddleWidth, match.paddleHeight )
	love.graphics.rectangle( "fill", match.rightPaddle.x, match.rightPaddle.y, match.paddleWidth, match.paddleHeight )

	match.powerUps:draw()
	love.graphics.setColor( love.math.colorFromBytes(246, 207, 133) )
	for _, entry in ipairs(match.balls) do
		local ball = entry.ball
		love.graphics.rectangle( "fill", ball.x, ball.y, ball.width, ball.height )
	end
end

function gameScreen:handleFullscreen()
	match:handleFullscreen()
	self:layoutScores()
end

function gameScreen:advanceFrame()
	match:advanceFrame()
end

function gameScreen:handleKeypresses(key, scancode, isrepeat)
	match:handleKeypresses(key, scancode, isrepeat)
end

function gameScreen:handleHeldkey(isDown)
	match:handleHeldkey(isDown)
end

return gameScreen
