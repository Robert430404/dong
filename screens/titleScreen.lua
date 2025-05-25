local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'

local titleScreen = {}

-- Initialize assets
local titleFont = love.graphics.newFont( "assets/doto-regular.ttf", 128 )
local titleText = love.graphics.newText( titleFont, "D.O.N.G" )

local startFont = love.graphics.newFont( "assets/doto-regular.ttf", 52 )
local startText = love.graphics.newText( startFont, "[ENTER] Start Game" )

local modeSelectFont = love.graphics.newFont( "assets/doto-regular.ttf", 36 )
local selectedMode = "two_player"
local modes = {
	{
		text = love.graphics.newText( modeSelectFont, "1 PLAYER" ),
		height = 0,
		width = 0,
	},
	{
		text = love.graphics.newText( modeSelectFont, "2 PLAYER" ),
		height = 0,
		width = 0,
	}
}

-- Compute offsets for centering
local titleWidth = (systemConfig:getScreenWidth() / 2) - titleText:getWidth() / 2
local titleHeight = (systemConfig:getScreenHeight() / 2) - (titleText:getHeight() / 2) - startText:getHeight()

local startWidth = (systemConfig:getScreenWidth() / 2) - startText:getWidth() / 2
local startHeight = (systemConfig:getScreenHeight() / 2) - (startText:getHeight() / 2) + startText:getHeight()

-- Handle fullscreen shift and recalculate the math
function titleScreen:handleFullscreen() 
	titleWidth = (systemConfig:getScreenWidth() / 2) - titleText:getWidth() / 2
	titleHeight = (systemConfig:getScreenHeight() / 2) - (titleText:getHeight() / 2) - startText:getHeight()

	startWidth = (systemConfig:getScreenWidth() / 2) - startText:getWidth() / 2
	startHeight = (systemConfig:getScreenHeight() / 2) - (startText:getHeight() / 2) + startText:getHeight()

	for _, mode in  ipairs(modes) do
		mode.height = 0
		mode.width = 0
	end
end

-- Render the screen
function titleScreen:render()
	love.graphics.setColor( love.math.colorFromBytes(46, 207, 133) )
	love.graphics.draw( titleText, titleWidth, titleHeight )
	love.graphics.draw( startText, startWidth, startHeight )

	for index, mode in ipairs(modes) do
		self:calculateModeOffsets( index )

		love.graphics.draw( mode.text, mode.width, mode.height )
	end

	love.graphics.setColor( love.math.colorFromBytes(99, 22, 22) )
	self:drawModeSelector()
end

function titleScreen:calculateModeOffsets( index )
	local mode = modes[index]

	if mode.width > 0 and mode.height > 0 then
		return
	end

	if index > 1 then
		mode.width = ((systemConfig:getScreenWidth() / 2) - mode.text:getWidth() / 2) + (mode.text:getWidth() / 1.5)
		mode.height = (systemConfig:getScreenHeight() / 2) - (mode.text:getHeight() / 2) + mode.text:getHeight() + startText:getHeight() + mode.text:getHeight()

		return
	end

	mode.width = ((systemConfig:getScreenWidth() / 2) - mode.text:getWidth() / 2) - (mode.text:getWidth() / 1.5)
	mode.height = (systemConfig:getScreenHeight() / 2) - (mode.text:getHeight() / 2) + mode.text:getHeight() + startText:getHeight() + mode.text:getHeight()
end

function titleScreen:handleModeSelection()
	opponent:setStatus(selectedMode == 'one_player')
end

function titleScreen:drawModeSelector()
	local currentMode = modes[2]

	if selectedMode == 'one_player' then
		currentMode = modes[1]
	end

	love.graphics.rectangle( "fill", currentMode.width, currentMode.height + currentMode.text:getHeight(), currentMode.text:getWidth(), 8 )
end

function titleScreen:advanceFrame()
	-- stubb to conform to the interface
	return
end

function titleScreen:handleKeypresses(key, scancode, isrepeat)
	if key == 'left' then
		selectedMode = 'one_player'

		self:handleModeSelection()
	end

	if key == 'right' then
		selectedMode = 'two_player'

		self:handleModeSelection()
	end

	return
end

function titleScreen:handleHeldkey(isDown)
	-- stubb to conform to the interface
	return
end

return titleScreen