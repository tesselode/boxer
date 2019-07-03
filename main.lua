local boxer = require 'boxer'

local box = boxer.Box {
	boxer.Ellipse {
		center = function() return 400 + 200 * math.sin(love.timer.getTime()) end,
		middle = function() return 300 + 200 * math.sin(love.timer.getTime() * 1.1) end,
		width = 64,
		height = 64,
		style = {idle = {fillColor = {.5, .5, .5}}},
	},
	boxer.Ellipse {
		center = function() return 400 + 200 * math.cos(love.timer.getTime() * 1.2) end,
		middle = function() return 300 + 200 * math.cos(love.timer.getTime() * 1.3) end,
		width = 64,
		height = 64,
		style = {idle = {fillColor = {.5, .5, .5}}},
	}
}

function love.draw()
	box:draw()
	local l, t, r, b = box:getChildrenBounds()
	love.graphics.rectangle('line', l, t, r - l, b - t)

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
