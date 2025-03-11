local renderer = require 'screens.renderer'
local keybindConfig = require 'config.keybindConfig'

function love.draw()
	renderer:render()
end