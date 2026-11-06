local registry = require 'powerups.registry'

local manager = {}
manager.__index = manager

function manager:new()
	return setmetatable({ active = {}, random = math.random }, self)
end

function manager:spawn(id, screenWidth, screenHeight)
	local definition = registry:get(id)
	if not definition then
		return nil
	end

	local item = definition:create(screenWidth, screenHeight)
	item.id = id
	table.insert(self.active, item)
	return item
end

function manager:reset(stepsPerSecond)
	self.active = {}
	self.stepsPerSecond = stepsPerSecond
	self.stepsUntilSpawn = self.random(3 * stepsPerSecond, 6 * stepsPerSecond)
	self.remainingIds = registry:list()
	self.pendingIndex = nil
end

function manager:advanceFrame(balls, screenWidth, screenHeight)
	if #self.remainingIds == 0 or #self.active > 0 then
		return
	end

	if self.stepsUntilSpawn > 0 then
		self.stepsUntilSpawn = self.stepsUntilSpawn - 1
	end
	if self.stepsUntilSpawn > 0 then
		return
	end

	if not self.pendingIndex then
		self.pendingIndex = self.random(1, #self.remainingIds)
	end

	local id = self.remainingIds[self.pendingIndex]
	local candidate = registry:get(id):create(screenWidth, screenHeight)
	for _, entry in ipairs(balls) do
		local ball = entry.ball
		local overlapsX = ball.x + ball.width >= candidate.x and ball.x <= candidate.x + candidate.width
		local overlapsY = ball.y + ball.height >= candidate.y and ball.y <= candidate.y + candidate.height
		if ball.isMoving and overlapsX and overlapsY then
			return
		end
	end

	self:spawn(id, screenWidth, screenHeight)
	table.remove(self.remainingIds, self.pendingIndex)
	self.pendingIndex = nil
	if #self.remainingIds > 0 then
		self.stepsUntilSpawn = self.random(3 * self.stepsPerSecond, 6 * self.stepsPerSecond)
	end
end

function manager:draw()
	for _, item in ipairs(self.active) do
		registry:get(item.id):draw(item)
	end
end

-- Find when a moving ball first overlaps an item within this step.
local function collisionTime(item, ball, velocity, remaining)
	local entryTime = 0
	local exitTime = remaining
	local function checkAxis(ballMin, ballMax, itemMin, itemMax, speed)
		if speed == 0 then
			return ballMax >= itemMin and ballMin <= itemMax
		end

		local first = (itemMin - ballMax) / speed
		local last = (itemMax - ballMin) / speed
		if first > last then
			first, last = last, first
		end

		entryTime = math.max(entryTime, first)
		exitTime = math.min(exitTime, last)
		return entryTime <= exitTime
	end

	if not checkAxis(ball.x, ball.x + ball.width, item.x, item.x + item.width, velocity.x) then
		return nil
	end
	if not checkAxis(ball.y, ball.y + ball.height, item.y, item.y + item.height, velocity.y) then
		return nil
	end

	return entryTime
end

function manager:findCollision(ball, velocity, remaining)
	local firstItem = nil
	local firstTime = remaining

	for _, item in ipairs(self.active) do
		local time = collisionTime(item, ball, velocity, remaining)
		if time and time <= firstTime then
			firstItem = item
			firstTime = time
		end
	end

	return firstItem, firstTime
end

function manager:activate(item, gameState, entry)
	for index, activeItem in ipairs(self.active) do
		if activeItem == item then
			table.remove(self.active, index)
			registry:get(item.id):apply(gameState, entry)
			return true
		end
	end

	return false
end

return manager
