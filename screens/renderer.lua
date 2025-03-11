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

function renderer:setScreen(screen)
	self.currentScreen = screen
end

return renderer