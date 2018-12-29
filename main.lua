local boxer = require 'boxer'

local box = boxer.Box {
	x = 50,
	y = 50,
	w = 100,
	h = 100,
	style = {
		idle = {fillColor = {.2, .2, .2}},
		hovered = {fillColor = {.4, .4, .4}},
		pressed = {fillColor = {.3, .3, .3}},
	},
	onPress = function() print 'hi!' end,
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
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(math.floor(collectgarbage('count')) .. 'kb')
end
