local boxer = require 'boxer'

local box = boxer.Box {
	w = 100,
	h = 100,
	style = {
		idle = {fillColor = {.2, .2, .2}},
		hovered = {fillColor = {.4, .4, .4}},
		pressed = {fillColor = {.3, .3, .3}},
	},
	onPress = function() print 'hi!' end,
	children = function()
		if love.keyboard.isDown('space') then
			return {
				boxer.Box {
					w = 10,
					h = 10,
					style = {idle = {fillColor = {1, 1, 1}}}
				},
			}
		else
			return {}
		end
	end,
}

function love.mousemoved(...)
	box:mousemoved(...)
end

function love.mousepressed(...)
	box:mousepressed(...)
end

function love.mousereleased(...)
	box:mousereleased(...)
end

function love.draw()
	box:draw()
end
