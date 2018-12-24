local boxer = require 'boxer'

local paragraph = boxer.paragraph {
	x = 50,
	y = 50,
	width = 400,
	font = love.graphics.newFont(18),
	text = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer vestibulum urna lectus, ac imperdiet lorem ultrices sed. Proin cursus, sapien vel cursus finibus, tellus massa euismod quam, finibus lobortis sem ex nec quam.',
	align = 'right',
	style = {
		idle = {
			color = function()
				return {1, 1, 1, .75 + .25 * math.sin(love.timer.getTime() * 4)}
			end
		}
	}
}

function love.update(dt)
	paragraph.width = paragraph.width - 10 * dt
end

function love.keypressed(key)
	paragraph.text = paragraph.text .. '\n'
end

function love.draw()
	paragraph:draw()
end
