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
		}
	}
}
print(box:getRect())

function love.draw()
	box:draw()
end
