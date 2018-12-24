local boxer = require 'boxer'

local box = boxer.box()

local time = 0

box:setWidth(100)
box:setHeight(200)
box:setX(function() return love.graphics.getWidth() - time * 100 end, 1)
box:setY(love.graphics.getHeight() / 2, .5)

function love.update(dt)
	time = time + dt
	box:setHeight(box:getHeight() + 50 * dt)
end

function love.draw()
	love.graphics.rectangle('fill', box:getRect())
end
