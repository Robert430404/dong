local opponent = {
	isEnabled = false;
}

function opponent:run()
	if self.isEnabled == true then
		print('i am running')

		return
	end

	print('i am not running')
end

function opponent:setStatus(isEnabled)
	self.isEnabled = isEnabled
end

return opponent