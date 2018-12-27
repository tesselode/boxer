local boxer = require 'boxer'

local box = boxer.box {
	x = 50,
	bottom = function() return love.graphics.getHeight() end,
	width = 100,
	height = 200,
	onPress = function() print 'hi!' end,
	onDrag = function(button, dx, dy)
		print(button, dx, dy)
	end,
	style = {
		idle = {
			fillColor = {.2, .2, .2},
		},
		hovered = {
			fillColor = {.4, .4, .4},
		},
		pressed = {
			fillColor = {.3, .3, .3},
			outlineColor = {.4, .4, .4},
		}
	},
	children = {
		boxer.box {
			name = 'steve',
			x = 50,
			y = -25,
			width = 100,
			height = 50,
			style = {
				idle = {
					fillColor = {.2, .2, .2},
					outlineColor = {1, 1, 1},
				},
				hovered = {
					fillColor = {.4, .4, .4},
				},
				pressed = {
					fillColor = {.3, .3, .3},
					outlineColor = {.4, .4, .4},
				}
			},
			onPress = function() print 'hello' end,
		},
		boxer.box {
			name = 'sara',
			x = 25,
			y = -25,
			width = 50,
			height = 50,
			style = {
				idle = {
					fillColor = {.2, .2, .2, .5},
					outlineColor = {1, 1, 1},
				},
				hovered = {
					fillColor = {.4, .4, .4, .5},
				},
				pressed = {
					fillColor = {.3, .3, .3, .5},
					outlineColor = {.4, .4, .4},
				}
			},
			transparent = true,
			onPress = function() print 'nice' end,
		},
	},
	clipChildren = function() return love.keyboard.isDown('space') end,
}

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
	box.children.sara:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.print(math.floor(collectgarbage 'count') .. 'kb')
end
