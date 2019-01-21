local boxer = require 'boxer'

local paragraph = boxer.paragraph {
	font = love.graphics.newFont(16),
	text = 'Libero repellendus sit consequatur laudantium inventore et. Est omnis qui occaecati maiores dolores asperiores harum. Vel corrupti libero voluptatem. Et fuga omnis dolore quisquam. Quos possimus velit dicta dignissimos et qui. Repudiandae et qui repudiandae in eos blanditiis. Ut ut eaque commodi voluptas aliquid iusto. Reprehenderit distinctio libero aut officia tempora.',
	width = function() return 400 + 100 * math.sin(love.timer.getTime()) end,
	height = 50,
}

local box = boxer.wrap {
	children = {paragraph},
	padding = 50,
}

box.style = {
	idle = {
		outlineColor = function()
			return 1, 1, 1
		end,
		lineWidth = 8,
		radiusX = 10,
		fillColor = {.5, .5, .5},
	},
}

box.onPress = function() print 'hello!' end

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
