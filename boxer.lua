local boxer = {
	_VERSION = 'Boxer',
	_DESCRIPTION = 'Layout library for LÖVE.',
	_URL = 'https://github.com/tesselode/boxer',
	_LICENSE = [[
		MIT License

		Copyright (c) 2019 Andrew Minnich

		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:

		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
	]]
}

local function count(...)
	local amount = 0
	for i = 1, select('#', ...) do
		if select(i, ...) then amount = amount + 1 end
	end
	return amount
end

--[[
	many properties in boxer can be set to either a raw value (number, string, etc.)
	or a function that returns a raw value. this function will call the function if
	necessary and return the raw value.
]]
local function get(value)
    if type(value) == 'function' then
        return value()
    else
        return value
    end
end

local Box = {}

-- gets a position along the x-axis of the box depending on the offset
-- (0 = left, 0.5 = center, 1 = right, etc.)
function Box:getX(offset)
    offset = offset or 0
    local x = get(self._x)
    x = x - self.width * self._anchorX
    return x + self.width * offset
end

-- gets a position along the y-axis of the box depending on the offset
-- (0 = top, 0.5 = middle, 1 = bottom, etc.)
function Box:getY(offset)
    offset = offset or 0
    local y = get(self._y)
    y = y - self.height * self._anchorY
    return y + self.height * offset
end

function Box:getRect()
	return self.x, self.y, self.width, self.height
end

-- gets a style property given the box's state
-- (idle/pressed/released)
function Box:getCurrentStyle(property)
    if not (self.style and self.style.idle) then return nil end
    if self._pressed and self.style.pressed then
        return get(self.style.pressed[property])
    elseif self._hovered and self.style.hovered then
        return get(self.style.hovered[property])
    end
	return get(self.style.idle[property])
end

function Box:containsPoint(x, y)
	return x >= self.left
	   and x <= self.right
	   and y >= self.top
	   and y <= self.bottom
end

--[[
	sets the position of a certain point along the x-axis of the box (defined by anchorX)
	0 = left, 0.5 = center, 1 = right, etc.
	x can be a number or a function that returns a number
]]
function Box:setX(x, anchorX)
	anchorX = anchorX or 0
	self._x, self._anchorX = x, anchorX
end

--[[
	sets the position of a certain point along the y-axis of the box (defined by anchorY)
	0 = top, 0.5 = middle, 1 = bottom, etc.
	y can be a number or a function that returns a number
]]
function Box:setY(y, anchorY)
	anchorY = anchorY or 0
	self._y, self._anchorY = y, anchorY
end

function Box:drawSelf()
    local _, _, width, height = self:getRect()
	if self:getCurrentStyle 'fillColor' then
		love.graphics.setColor(self:getCurrentStyle 'fillColor')
		love.graphics.rectangle('fill', 0, 0, width, height,
        self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
	end
    if self:getCurrentStyle 'outlineColor' then
        love.graphics.setColor(self:getCurrentStyle 'outlineColor')
        love.graphics.setLineWidth(self:getCurrentStyle 'lineWidth' or 1)
        love.graphics.rectangle('line', 0, 0, width, height,
            self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
    end
end

function Box:draw()
    if self.hidden then return end
    love.graphics.push 'all'
    love.graphics.translate(self:getRect())
    self:drawSelf()
    love.graphics.pop()
end

function Box:__index(k)
    if k == 'x' or k == 'left' then return self:getX(0) end
    if k == 'center'           then return self:getX(.5) end
    if k == 'right'            then return self:getX(1) end
    if k == 'y' or k == 'top'  then return self:getY(0) end
    if k == 'middle'           then return self:getY(.5) end
    if k == 'bottom'           then return self:getY(1) end
    if k == 'width'            then return get(self._width) end
    if k == 'height'           then return get(self._height) end
    return Box[k]
end

function Box:__newindex(k, v)
    if k == 'x' or k == 'left' then
        self:setX(v, 0)
    elseif k == 'center' then
        self:setX(v, .5)
    elseif k == 'right' then
        self:setX(v, 1)
    elseif k == 'y' or k == 'top' then
        self:setY(v, 0)
    elseif k == 'middle' then
        self:setY(v, .5)
    elseif k == 'bottom' then
        self:setY(v, 1)
    elseif k == 'width' then
        self._width = v
    elseif k == 'height' then
        self._height = v
    else
        rawset(self, k, v)
    end
end

function boxer.box(options)
    if count(options.x, options.left, options.center, options.right) > 1 then
        error('Cannot provide more than one horizontal position property', 2)
    end
    if count(options.y, options.top, options.middle, options.bottom) > 1 then
        error('Cannot provide more than one vertical position property', 2)
    end
    local box = setmetatable({}, Box)
    box.x, box.y, box.width, box.height = 0, 0, 0, 0
    for k, v in pairs(options) do
        box[k] = v
    end
    return box
end

return boxer
