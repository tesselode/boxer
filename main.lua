local boxer = require 'boxer'

local box = boxer.Box {
	x = 50,
	y = 50,
	width = 50,
	height = 50,
	style = {idle = {fillColor = {.1, .1, .1}}}
}
for _ = 1, 5 do
	table.insert(box.children, boxer.Ellipse {
		center = 400,
		middle = 300,
		width = 50,
		height = 50,
		style = {idle = {fillColor = {.5, .5, .5}}},
	})
end

function love.update(dt)
	for i, child in ipairs(box.children) do
		child.center = child.center + 100 * math.sin(love.timer.getTime() * (1 + i/10)) * dt
		child.middle = child.middle + 100 * math.cos(love.timer.getTime() * (1.05 + i/10)) * dt
	end
end

function love.keypressed(key)
	if key == 'space' then
		box:wrap()
	end
end

function love.draw()
	box:wrap('moveChildren', 16)
	box:draw()

	love.graphics.print('Memory usage: ' .. math.floor(collectgarbage 'count') .. 'kb')
end
