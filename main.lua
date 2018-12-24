local boxer = require 'boxer'

local time = 0

local box = boxer.box {
	right = function() return love.graphics.getWidth() - time * 100 end,
	middle = love.graphics.getHeight() / 2,
	width = 100,
	height = 200,
}

local box2 = boxer.box {
	left = 50,
	top = 50,
	width = 50,
	height = 50,
}

function love.update(dt)
	time = time + dt
	box.height = box.height + 50 * dt
end

function love.draw()
	love.graphics.rectangle('fill', box:getRect())
	love.graphics.rectangle('fill', box2:getRect())
	love.graphics.print(tostring(box:overlaps(box2.x, box2.y, box2.width, box2.height)))
end
