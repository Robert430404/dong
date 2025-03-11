local renderer = require 'screens.renderer'
local keybindConfig = require 'config.keybindConfig'

function love.draw()
	love.graphics.setColor( love.math.colorFromBytes(255, 255, 255) )
	renderer:render()
end