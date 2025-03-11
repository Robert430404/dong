local renderer = require 'screens.renderer'

local keybindConfig = {
	isFullscreen = false,
	isInGame = false
}

function keybindConfig:handleFullscreen()
	self.isFullscreen = not self.isFullscreen

	love.window.setFullscreen( self.isFullscreen, "exclusive" )

	renderer:handleFullscreen()
end

function keybindConfig:handleEscape()
	love.event.quit()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "f11" then
		return keybindConfig:handleFullscreen();
	end

  if key == "escape" then
    return love.event.quit()
  end

  if key == "return" and not keybindConfig.isInGame then
  	keybindConfig.isInGame = true

    return renderer:setScreen("game")
  end

  renderer:handleKeypresses( key, scancode, isrepeat )
end

return keybindConfig