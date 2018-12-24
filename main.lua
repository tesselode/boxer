local boxer = require 'boxer'

local box = boxer.box {
	left = 250,
	top = 50,
	width = 50,
	height = 50,
	style = {
		idle = {
			lineWidth = 2,
			radiusX = 4,
			outlineColor = {1, 1, 1},
			fillColor = {.2, .2, .2},
		},
		hovered = {fillColor = {.4, .4, .4}},
		pressed = {fillColor = {.3, .3, .3}},
	},
	onPress = function() print 'hi!' end,
	children = {
		boxer.text {
			x = 0,
			y = 0,
			font = love.graphics.newFont(32),
			text = 'Hello world!',
			style = {
				idle = {
					color = {1, .8, .8},
				},
				hovered = {
					color = {1, 1, 1},
				},
			},
		}
	}
}

function love.update(dt)
	box.x = box.x + 50 * dt
	box.y = box.y + 25 * dt
	box.height = box.height + 50 * dt
end

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
