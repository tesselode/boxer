local boxer = require 'boxer'

local box = boxer.Box {
	x = 50,
	y = 50,
	width = 100,
	height = 200,
	style = {idle = {fillColor = {.2, .2, .2}}},
	children = {
		boxer.Text {
			font = love.graphics.newFont(32),
			text = 'test text please ignore',
		}
	},
	clipChildren = true,
}

function love.draw()
	box:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
