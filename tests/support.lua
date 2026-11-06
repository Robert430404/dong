local support = {}

function support.newGame()
	local modules = {
		'main',
		'config.keybindConfig',
		'config.systemConfig',
		'screens.renderer',
		'screens.titleScreen',
		'screens.gameScreen',
		'opponent',
		'powerups.manager',
		'powerups.registry',
		'powerups.splitBall',
		'powerups.slowDown',
		'powerups.speedShift',
		'powerups.layout'
	}

	for _, name in ipairs(modules) do
		package.loaded[name] = nil
	end

	local textInput = nil
	local screenWidth = 1280
	local screenHeight = 720
	local dpiScale = 1
	local drawnText = {}
	local fonts = {}
	local shapes = {}
	local transform = {}
	love = {
		graphics = {
			getWidth = function() return screenWidth end,
			getHeight = function() return screenHeight end,
			getDPIScale = function() return dpiScale end,
			newFont = function(path, size, hinting, density)
				local font = { size = size, density = density }
				table.insert(fonts, font)
				return font
			end,
			newText = function(font, value)
				local text = value
				return {
					getWidth = function() return 100 end,
					getHeight = function() return 40 end,
					set = function(_, newText) text = newText end,
					setFont = function(_, newFont) font = newFont end,
					getFont = function() return font end,
					getText = function() return text end
				}
			end,
			setColor = function() end,
			draw = function(text) table.insert(drawnText, text:getText()) end,
			rectangle = function(mode, x, y, width, height)
				table.insert(shapes, { mode = mode, x = x, y = y, width = width, height = height })
			end,
			line = function(...)
				table.insert(shapes, { mode = 'polyline', points = { ... } })
			end,
			setLineWidth = function() end,
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
	function fixture:getShapes()
		return shapes
	end
	function fixture:setDPIScale(scale)
		dpiScale = scale
	end
	function fixture:getFonts()
		return fonts
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
