local renderer = require 'screens.renderer'
local keybindConfig = require 'config.keybindConfig'
local systemConfig = require 'config.systemConfig'
local opponent = require 'opponent'

local step = 1 / systemConfig:getTargetFrames()
local accumulator = 0

function love.load()
	math.randomseed(os.time())
end

function love.resize()
	renderer:handleFullscreen()
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
	love.graphics.setColor( love.math.colorFromBytes(255, 255, 255) )
	renderer:render()
end
