local boxer = require 'boxer'

local ellipse = boxer.Ellipse {
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
	children = {
		boxer.Text {
			center = 200,
			middle = 100,
			font = love.graphics.newFont(32),
			text = 'test text please ignore',
			style = {
				hovered = {
					shadowColor = {0, 0, 0},
					shadowOffsetX = 5,
				}
			}
		}
	}
}

local image = boxer.Image {
	image = love.graphics.newImage 'bean man.jpg',
	center = love.graphics.getWidth() / 2,
	middle = love.graphics.getHeight() / 2,
	scaleX = .25,
	height = 100,
}

local container = boxer.Box()
container.children = {ellipse, image}
container:wrap(16)
container.x = 16
container.y = 16
container.style = {idle = {fillColor = {.1, .1, .1}}}

function love.mousemoved(...)
	container:mousemoved(...)
end

function love.mousepressed(...)
	container:mousepressed(...)
end

function love.mousereleased(...)
	container:mousereleased(...)
end

function love.draw()
	container:draw()
end
