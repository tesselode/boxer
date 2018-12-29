local boxer = require 'boxer'

local box = boxer.Box {
	x = 50,
	y = 50,
	width = 100,
	height = 100,
	style = {
		idle = {fillColor = {.2, .2, .2}},
		hovered = {fillColor = {.4, .4, .4}},
		pressed = {fillColor = {.3, .3, .3}},
	},
	children = {
		boxer.Text {
			font = love.graphics.newFont(32),
			text = 'hello world!',
			x = 0,
			y = 0,
			transparent = true,
		},
		boxer.Image {
			image = love.graphics.newImage 'bean man.jpg',
			x = 0,
			y = 50,
		}
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
end
