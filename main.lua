local boxer = require 'boxer'

local box = boxer.box {
	x = 50,
	bottom = function() return love.graphics.getHeight() end,
	width = 100,
	height = 200,
	onPress = function() print 'hi!' end,
	onEnter = function() print 'enter' end,
	onLeave = function() print 'leave' end,
	style = {
		idle = {
			fillColor = function()
				return {.2, .2, .2, .5 + .5 * math.sin(love.timer.getTime())}
			end,
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
			x = 25,
			y = -25,
			width = 50,
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
	box:draw()
end
