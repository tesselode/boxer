local boxer = require 'boxer'

local box = boxer.Box {
	x = 50,
	y = 50,
	width = 100,
	height = 200,
	style = {
		idle = {
			fillColor = {.5, .5, .5},
		}
	},
	boxer.Text {
		font = love.graphics.newFont(32),
		text = 'hello world!',
	},
	boxer.Image {
		image = love.graphics.newImage 'bean man.jpg',
		y = 32,
		scaleX = .1,
		scaleY = .1,
	}
}

function love.draw()
	box:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
