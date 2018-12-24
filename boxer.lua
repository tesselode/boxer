local boxer = {}

-- returns whether exactly one of the arguments evaluates to true
local function one(...)
	local result = false
	for i = 1, select('#', ...) do
		local arg = select(i, ...)
		if not result then
			if arg then result = true end
		else
			if arg then return false end
		end
	end
	return result
end

local function get(value)
	return type(value) == 'function' and value() or value
end

local Box = {}

function Box:__index(k)
	if k == 'x' or k == 'left' then return self:getX() end
	if k == 'center'           then return self:getX(.5) end
	if k == 'right'            then return self:getX(1) end
	if k == 'y' or k == 'top'  then return self:getY() end
	if k == 'middle'           then return self:getY(.5) end
	if k == 'bottom'           then return self:getY(1) end
	if k == 'width'            then return self:getWidth() end
	if k == 'height'           then return self:getHeight() end
	return Box[k]
end

function Box:__newindex(k, v)
	if k == 'x' or k == 'left' then self:setX(v) return end
	if k == 'center'           then self:setX(v, .5) return end
	if k == 'right'            then self:setX(v, 1) return end
	if k == 'y' or k == 'top'  then self:setY(v) return end
	if k == 'middle'           then self:setY(v, .5) return end
	if k == 'bottom'           then self:setY(v, 1) return end
	if k == 'width'            then self:setWidth(v) return end
	if k == 'height'           then self:setHeight(v) return end
	rawset(self, k, v)
end

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

function Box:_init(options)
	self._x, self._anchorX = nil, nil
	self._y, self._anchorY = nil, nil
	self._width, self._height = nil, nil
	assert(one(options.x, options.left, options.center, options.right))
	assert(one(options.y, options.top, options.middle, options.bottom))
	assert(options.width)
	assert(options.height)
	self.width = options.width
	self.height = options.height
	if options.x then self.x = options.x end
	if options.left then self.left = options.left end
	if options.center then self.center = options.center end
	if options.right then self.right = options.right end
	if options.y then self.y = options.y end
	if options.top then self.top = options.top end
	if options.middle then self.middle = options.middle end
	if options.bottom then self.bottom = options.bottom end
end

function boxer.box(options)
	local box = setmetatable({}, Box)
	box:_init(options)
	return box
end

return boxer
