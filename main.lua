local boxer = require 'boxer'

local Animal = boxer.Class()

Animal.properties = {
	times = {required = true}
}

local Dog = Animal:extend()

Dog.properties = {
	times = {type = 'dynamic'}
}

function Dog:new(times)
	self.times = times
end

function Dog:bark()
	print()
	for _ = 1, self.times do
		print 'borkf'
	end
end

local spot = Dog()

function love.keypressed()
	spot:bark()
end
