local renderer = require 'screens.renderer'
local keybindConfig = require 'config.keybindConfig'
local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'

local step = 1 / systemConfig:getTargetFrames()
local accumulator = 0

function love.load()
	math.randomseed(os.time())
	love.keyboard.setTextInput(false)
end

function love.update(dt)
	accumulator = accumulator + math.min(dt, 0.25)
	while accumulator >= step do
		renderer:handleHeldkey(love.keyboard.isDown)
		renderer:advanceFrame()
		accumulator = accumulator - step
	end
end

function love.draw()
	local scale, offsetX, offsetY = systemConfig:getViewport()
	love.graphics.push()
	love.graphics.translate(offsetX, offsetY)
	love.graphics.scale(scale)
	love.graphics.setColor( love.math.colorFromBytes(255, 255, 255) )
	renderer:render()
	love.graphics.pop()
end
