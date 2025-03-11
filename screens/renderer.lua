local titleScreen = require 'screens.titleScreen'
local gameScreen = require 'screens.gameScreen'

local renderer = {
	currentScreen = 'title',

	title = titleScreen,
	game = gameScreen
}

function renderer:render()
	self[self.currentScreen]:render()
end

function renderer:handleFullscreen()
	self[self.currentScreen]:handleFullscreen()
end

function renderer:setScreen(screen)
	self.currentScreen = screen

	self:handleFullscreen()
end

function renderer:handleKeypresses(key, scancode, isrepeat)
	self[self.currentScreen]:handleKeypresses(key, scancode, isrepeat)
end

function renderer:handleHeldkey(isDown)
	self[self.currentScreen]:handleHeldkey(isDown)
end

return renderer