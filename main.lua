local boxer = require 'boxer'

local box = boxer.box {
	center = love.graphics.getWidth() / 2,
	y = 50,
	width = function() return 100 + 100 * math.sin(love.timer.getTime()) end,
	height = 100,
	style = {
		idle = {
			outlineColor = function()
				return 1, 1, 1
			end,
			lineWidth = 8,
			radiusX = 10,
			fillColor = {.5, .5, .5},
		},
	},
	onPress = function() print 'hello!' end,
	children = {
		boxer.box {
			x = 25,
			y = 75,
			width = 200,
			height = 200,
			style = {
				idle = {
					fillColor = {1, 0, 0},
				},
				hovered = {
					fillColor = {1, 1, 1},
				}
			},
			onPress = function() print 'hi!' end,
		},
	},
	clipChildren = true,
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
