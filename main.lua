local boxer = require 'boxer'

local image = boxer.image {
	image = love.graphics.newImage 'bean man.jpg',
	scaleX = .25,
	scaleY = .25,
	style = {
		idle = {color = {1, 1, 1, .5}},
		hovered = {color = {1, 1, 1, 1}},
	}
}

local box = boxer.wrap {
	children = {image},
	padding = 25,
}

box.x, box.y = 50, 50
box.style = {
	idle = {
		outlineColor = function()
			return 1, 1, 1
		end,
		lineWidth = 8,
		radiusX = 10,
		fillColor = {.5, .5, .5},
	},
}

box.onPress = function() print 'hello!' end

function love.mousemoved(x, y, dx, dy, istouch)
	box:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	box:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	box:mousereleased(x, y, button, istouch, presses)
end

function love.draw()
	box:draw()
end
