local renderer = require 'screens.renderer'
local keybindConfig = require 'config.keybindConfig'

function love.update(dt)
	renderer:handleHeldkey(love.keyboard.isDown)
end

function love.draw()
	love.graphics.setColor( love.math.colorFromBytes(255, 255, 255) )
	renderer:render()
end