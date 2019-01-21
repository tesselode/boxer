local boxer = require 'boxer'

local box = boxer.wrap {
	children = {
		boxer.text {
			font = love.graphics.newFont(32),
			text = 'Hello world!',
			scaleX = function() return .5 + math.sin(love.timer.getTime()) end,
			scaleY = 1.5,
		}
	},
	padding = 50,
}

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
