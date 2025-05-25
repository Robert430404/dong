local opponent = {
	isEnabled = false
}

function opponent:run(gameState)
	if self.isEnabled == false then
		return
	end

	print(gameState)
end

function opponent:setStatus(isEnabled)
	self.isEnabled = isEnabled
end

return opponent