local boxer = require 'boxer'

local box = boxer.box {
	center = love.graphics.getWidth() / 2,
	y = 50,
	width = function() return 100 + 100 * math.sin(love.timer.getTime()) end,
	height = 100,
}
print(box:getRect())

function love.draw()
	love.graphics.rectangle('fill', box:getRect())
end
