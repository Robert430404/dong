local splitBall = require 'powerups.splitBall'
local slowDown = require 'powerups.slowDown'
local speedShift = require 'powerups.speedShift'

local registry = {}
local definitions = {}
local ids = {}

function registry:register(id, definition)
	if type(id) ~= 'string' or id == '' or type(definition) ~= 'table' then
		return false
	end
	if type(definition.create) ~= 'function' or type(definition.draw) ~= 'function' or type(definition.apply) ~= 'function' then
		return false
	end
	if definitions[id] then
		return false
	end

	definitions[id] = definition
	table.insert(ids, id)
	return true
end

function registry:get(id)
	return definitions[id]
end

function registry:list()
	local result = {}
	for _, id in ipairs(ids) do
		table.insert(result, id)
	end
	return result
end

registry:register(splitBall.id, splitBall)
registry:register(slowDown.id, slowDown)
registry:register(speedShift.id, speedShift)

return registry
