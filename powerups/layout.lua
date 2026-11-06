local layout = {}

function layout:create(screenWidth, screenHeight)
	local width = 32
	local height = 48

	return {
		x = screenWidth / 2 - width / 2,
		y = screenHeight * 0.65 - height / 2,
		width = width,
		height = height
	}
end

return layout
