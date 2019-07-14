local boxer = require 'boxer'

local box = boxer.Box {
	style = {idle = {fillColor = {.1, .1, .1}}},
	children = {
		boxer.Ellipse {
			x = 50, y = 50, width = 50, height = 50,
			style = {idle = {fillColor = {.5, .5, .5}}},
		},
		boxer.Ellipse {
			x = 150, y = 150, width = 50, height = 50,
			style = {idle = {fillColor = {.5, .5, .5}}},
		},
		boxer.Ellipse {
			x = 100, y = 200, width = 50, height = 50,
			style = {idle = {fillColor = {.5, .5, .5}}},
		},
	},
}
	:wrap('moveBox', 16)
	:shiftChildren(100, 100)

function love.keypressed(key)
	if key == 'space' then
		box:wrap()
	end
end

function love.draw()
	box:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
