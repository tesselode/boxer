local boxer = {}

local function get(value)
	return type(value) == 'function' and value() or value
end

local Box = {}
Box.__index = Box

function Box:getX(offset)
	offset = offset or 0
	local width = self:getWidth()
	local x = get(self._x)
	x = x - width * self._anchorX
	return x + width * offset
end

function Box:getY(offset)
	offset = offset or 0
	local height = self:getHeight()
	local y = get(self._y)
	y = y - height * self._anchorY
	return y + height * offset
end

function Box:getWidth()
	return get(self._width)
end

function Box:getHeight()
	return get(self._height)
end

function Box:getRect()
	return self:getX(), self:getY(), self:getWidth(), self:getHeight()
end

function Box:setX(x, anchorX)
	anchorX = anchorX or 0
	self._x, self._anchorX = x, anchorX
end

function Box:setY(y, anchorY)
	anchorY = anchorY or 0
	self._y, self._anchorY = y, anchorY
end

function Box:setWidth(width)
	self._width = width
end

function Box:setHeight(height)
	self._height = height
end

function Box:_init()
	self._x, self._anchorX = nil, nil
	self._y, self._anchorY = nil, nil
	self._width, self._height = nil, nil
end

function boxer.box(options)
	local box = setmetatable({}, Box)
	box:_init(options)
	return box
end

return boxer
