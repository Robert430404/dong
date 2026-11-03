local support = {}

function support.newGame()
	local modules = {
		'main',
		'config.keybindConfig',
		'config.systemConfig',
		'screens.renderer',
		'screens.titleScreen',
		'screens.gameScreen',
		'opponent'
	}

	for _, name in ipairs(modules) do
		package.loaded[name] = nil
	end

	local textInput = nil
	local screenWidth = 1280
	local screenHeight = 720
	local drawnText = {}
	local transform = {}
	love = {
		graphics = {
			getWidth = function() return screenWidth end,
			getHeight = function() return screenHeight end,
			newFont = function() return {} end,
			newText = function(font, value)
				local text = value
				return {
					getWidth = function() return 100 end,
					getHeight = function() return 40 end,
					set = function(_, newText) text = newText end,
					getText = function() return text end
				}
			end,
			setColor = function() end,
			draw = function(text) table.insert(drawnText, text:getText()) end,
			rectangle = function() end,
			push = function() end,
			pop = function() end,
			translate = function(x, y) transform.x, transform.y = x, y end,
			scale = function(scale) transform.scale = scale end
		},
		math = { colorFromBytes = function(...) return ... end },
		keyboard = {
			isDown = function() return false end,
			setTextInput = function(enabled) textInput = enabled end
		},
		window = { setFullscreen = function() end },
		event = {}
	}

	require 'main'
	love.load()

	local fixture = {
		game = require 'screens.gameScreen',
		renderer = require 'screens.renderer',
		opponent = require 'opponent',
		textInput = textInput
	}

	fixture.game:handleFullscreen()
	function fixture:setScreenSize(width, height)
		screenWidth = width
		screenHeight = height
	end
	function fixture:getDrawnText()
		return drawnText
	end
	function fixture:getTransform()
		return transform
	end

	return fixture
end

function support.near(actual, expected)
	assert(math.abs(actual - expected) < 0.00001, actual .. ' ~= ' .. expected)
end

function support.noKeysDown()
	return false
end

return support
