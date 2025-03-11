local systemConfig = require 'config.systemConfig'

local titleScreen = {}

-- Initialize assets
local titleFont = love.graphics.newFont( "assets/doto-regular.ttf", 128 )
local titleText = love.graphics.newText( titleFont, "D.O.N.G" )

local startFont = love.graphics.newFont( "assets/doto-regular.ttf", 52 )
local startText = love.graphics.newText( startFont, "[ENTER] Start Game" )

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
end

-- Render the screen
function titleScreen:render()
	love.graphics.setColor( love.math.colorFromBytes(46, 207, 133) )
	love.graphics.draw( titleText, titleWidth, titleHeight )
	love.graphics.draw( startText, startWidth, startHeight )
end

return titleScreen