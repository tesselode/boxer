local boxer = require 'boxer'

local time = 0

local box = boxer.box {
	right = function() return love.graphics.getWidth() - time * 100 end,
	middle = love.graphics.getHeight() / 2,
	width = 100,
	height = 200,
}

function love.update(dt)
	time = time + dt
	box.height = box.height + 50 * dt
end

function love.draw()
	love.graphics.rectangle('fill', box:getRect())
end
