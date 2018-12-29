local boxer = require 'boxer'

local Animal = boxer.Class()

function Animal:new(times)
	self.times = times
end

function Animal:say(sound)
	for _ = 1, self.times do
		print(sound)
	end
end

local Dog = Animal:extend()

function Dog:bark()
	self:say 'borkf'
end

local spot = Dog(5)
local buster = Dog(1)
buster:bark()
print()
spot:bark()
