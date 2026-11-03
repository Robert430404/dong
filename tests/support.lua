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
	love = {
		graphics = {
			getWidth = function() return 1280 end,
			getHeight = function() return 720 end,
			newFont = function() return {} end,
			newText = function()
				return {
					getWidth = function() return 100 end,
					getHeight = function() return 40 end,
					set = function() end
				}
			end
		},
		keyboard = {
			isDown = function() return false end,
			setTextInput = function(enabled) textInput = enabled end
		},
		window = {},
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
	return fixture
end

function support.near(actual, expected)
	assert(math.abs(actual - expected) < 0.00001, actual .. ' ~= ' .. expected)
end

function support.noKeysDown()
	return false
end

return support
