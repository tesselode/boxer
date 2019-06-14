local boxer = require 'boxer'

local text = boxer.Text {
	y = function(self) return self.x end,
	font = love.graphics.newFont(32),
	text = 'test text please ignore',
	style = {
		idle = {
			shadowColor = {.5, .5, .5},
			shadowOffsetX = function(self)
				return self.x / 50
			end,
		}
	}
}

function love.update(dt)
	text.x = text.x + 100 * dt
end

function love.draw()
	text:draw()
end
