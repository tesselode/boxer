local boxer = require 'boxer'

local box = boxer.wrap {
	children = {
		boxer.text {
			x = 100,
			y = 100,
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
		},
		boxer.text {
			x = 200,
			y = function() return love.graphics.getHeight() / 2 end,
			font = love.graphics.newFont(16),
			text = 'Wow nice it works!',
			style = {
				idle = {
					color = {1, .8, .8},
				},
				hovered = {
					color = {1, 1, 1},
				},
			},
		},
	},
	padding = -10,
}
box.style = {
	idle = {
		lineWidth = 2,
		radiusX = 32,
		outlineColor = {1, 1, 1},
		fillColor = {.2, .2, .2},
	},
	hovered = {fillColor = {.4, .4, .4}},
	pressed = {fillColor = {.3, .3, .3}},
}
box.onPress = function() print 'hi!' end
table.insert(box.children, boxer.box {
	x = function() return 150 + 300 * math.sin(love.timer.getTime()) end,
	y = 150,
	width = 50,
	height = 50,
	children = {
		boxer.image {
			image = love.graphics.newImage 'bean man.jpg',
			x = -50,
			y = -50,
		}
	},
	clipChildren = true,
})
table.insert(box.children, boxer.box {
	x = function() return 150 + 300 * math.sin(love.timer.getTime() * 1.5) end,
	y = 75,
	width = 50,
	height = 50,
	children = {
		boxer.image {
			image = love.graphics.newImage 'bean man.jpg',
			x = function() return -50 + 50 * math.sin(love.timer.getTime()) end,
			y = -50,
		}
	},
	clipChildren = true,
})
box.clipChildren = true

function love.update(dt)
	box.height = box.height + 5 * dt
end

function love.mousemoved(x, y, dx, dy, istouch)
	box:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	box:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	box:mousereleased(x, y, button, istouch, presses)
end

function love.draw()
	box:draw()
end
