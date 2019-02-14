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

local image = boxer.image {
	image = love.graphics.newImage 'bean man.jpg',
	center = love.graphics.getWidth() / 2,
	middle = love.graphics.getHeight() / 2,
	scaleX = .25,
	height = 100,
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
	image:draw()
end
