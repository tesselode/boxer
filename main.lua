local boxer = require 'boxer'

local box = boxer.box {
	left = 250,
	top = 50,
	width = 50,
	height = 50,
	style = {
		idle = {
			lineWidth = 2,
			radiusX = 4,
			outlineColor = {1, 1, 1},
			fillColor = {.2, .2, .2},
		},
		hovered = {fillColor = {.4, .4, .4}},
		pressed = {fillColor = {.3, .3, .3}},
	},
	onPress = function() print 'hi!' end,
}

local text = boxer.text {
	width = 100,
	right = function() return box.center end,
	middle = function() return box.middle end,
	font = love.graphics.newFont(32),
	text = 'Hello world!',
	style = {
		idle = {
			color = {1, .8, .8},
		},
		hovered = {
			color = {1, 1, 1},
		},
	},
}

local image = boxer.image {
	image = love.graphics.newImage 'bean man.jpg',
	scaleX = .5,
	scaleY = .5,
	right = function() return love.graphics.getWidth() end,
	middle = function() return love.graphics.getHeight() / 2 + 100 * math.sin(love.timer.getTime()) end,
	style = {
		idle = {color = {1, .8, .8}},
		hovered = {color = {1, 1, 1}},
		pressed = {color = {.5, .5, .5}},
	},
}

function love.update(dt)
	box.height = box.height + 50 * dt
end

function love.mousemoved(x, y, dx, dy, istouch)
	box:mousemoved(x, y, dx, dy, istouch)
	text:mousemoved(x, y, dx, dy, istouch)
	image:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	box:mousepressed(x, y, button, istouch, presses)
	text:mousepressed(x, y, button, istouch, presses)
	image:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	box:mousereleased(x, y, button, istouch, presses)
	text:mousereleased(x, y, button, istouch, presses)
	image:mousereleased(x, y, button, istouch, presses)
end

function love.draw()
	box:draw()
	text:draw()
	image:draw()
end
