local renderer = require 'screens.renderer'
local keybindConfig = require 'config.keybindConfig'
local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'

local initTime

function love.load()
	initTime = love.timer.getTime()
end

function love.resize()
	renderer:handleFullscreen()
end

function love.update(dt)
	local currentTime = love.timer.getTime()
	local timeDelta = currentTime - initTime

	if timeDelta > 1 / systemConfig:getTargetFrames() then
		renderer:advanceFrame()
		renderer:handleHeldkey(love.keyboard.isDown)
		initTime = love.timer.getTime()
	end
end

function love.draw()
	love.graphics.setColor( love.math.colorFromBytes(255, 255, 255) )
	renderer:render()
end