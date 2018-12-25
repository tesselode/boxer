local boxer = require 'boxer'

local box = boxer.box {
	x = 50,
	bottom = function() return love.graphics.getHeight() end,
	width = 100,
	height = 200,
	onPress = function() print 'hi!' end,
	style = {
		idle = {
			fillColor = {.2, .2, .2},
		},
		hovered = {
			fillColor = {.4, .4, .4},
		},
		pressed = {
			fillColor = {.3, .3, .3},
			outlineColor = {.4, .4, .4},
		}
	},
	children = {
		boxer.text {
			x = 25,
			y = 25,
			font = love.graphics.newFont(18),
			text = 'Hello world!',
			width = 50,
		}
	}
}

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
