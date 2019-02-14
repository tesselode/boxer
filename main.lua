local boxer = require 'boxer'

local ellipse = boxer.ellipse {
	right = love.graphics.getWidth(),
	bottom = love.graphics.getHeight(),
	width = 400,
	height = 200,
	style = {
		idle = {
			fillColor = {.25, .25, .25},
			outlineColor = {1, 1, 1},
			lineWidth = 4,
		},
		hovered = {
			fillColor = {.5, .5, .5},
		},
	},
}

function love.mousemoved(...)
	ellipse:mousemoved(...)
end

function love.mousepressed(...)
	ellipse:mousepressed(...)
end

function love.mousereleased(...)
	ellipse:mousereleased(...)
end

function love.draw()
	ellipse:draw()
end
