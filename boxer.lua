local boxer = {}

--- utilities ---

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

-- merges tables together
local function merge(...)
	local t = {}
	for i = 1, select('#', ...) do
		local t2 = select(i, ...)
		for k, v in pairs(t2) do
			t[k] = v
		end
	end
	return t
end

-- gets the value of a property that can be either a function or a raw value
local function get(value)
	return type(value) == 'function' and value() or value
end

--- box ---

local Box = {}

function Box:_getStyle()
	if not (self.style and self.style.idle) then return nil end
	if self.pressed and self.style.pressed then
		return merge(self.style.idle, self.style.pressed)
	end
	if self.hovered and self.style.hovered then
		return merge(self.style.idle, self.style.hovered)
	end
	return self.style.idle
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

function Box:containsPoint(x, y)
	return x >= self.left
	   and x <= self.right
	   and y >= self.top
	   and y <= self.bottom
end

function Box:overlaps(a, b, c, d)
	local x, y, width, height
	if type(a) == 'table' then
		assert(a.x and a.y and a.width and a.height)
		x, y, width, height = a.x, a.y, a.width, a.height
	else
		x, y, width, height = a, b, c, d
	end
	return self.left < x + width
	   and self.right > x
	   and self.top < y + height
	   and self.bottom > y
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

function Box:mousemoved(x, y, dx, dy, istouch)
	self.hovered = self:containsPoint(x, y)
end

function Box:mousepressed(x, y, button, istouch, presses)
	if not self.pressed and self.hovered then
		self.pressed = button
	end
end

function Box:mousereleased(x, y, button, istouch, presses)
	if button == self.pressed then
		self.pressed = false
		if self.onPress and self.hovered then
			self.onPress()
		end
	end
end

function Box:draw()
	local style = self:_getStyle()
	if not style then return end
	local x, y, width, height = self:getRect()
	if style.outlineColor then
		love.graphics.setColor(style.outlineColor)
		love.graphics.setLineWidth(style.lineWidth or 1)
		love.graphics.rectangle('line', x, y, width, height, style.radiusX, style.radiusY)
	end
	if style.fillColor then
		love.graphics.setColor(style.fillColor)
		love.graphics.rectangle('fill', x, y, width, height, style.radiusX, style.radiusY)
	end
end

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

function Box:_init(options, sizeIsOptional)
	self._x, self._anchorX = nil, nil
	self._y, self._anchorY = nil, nil
	self._width, self._height = nil, nil
	self.hovered = false
	self.pressed = false
	assert(one(options.x, options.left, options.center, options.right))
	assert(one(options.y, options.top, options.middle, options.bottom))
	if not sizeIsOptional then
		assert(options.width)
		assert(options.height)
	end
	if options.width then self.width = options.width end
	if options.height then self.height = options.height end
	if options.x then self.x = options.x end
	if options.left then self.left = options.left end
	if options.center then self.center = options.center end
	if options.right then self.right = options.right end
	if options.y then self.y = options.y end
	if options.top then self.top = options.top end
	if options.middle then self.middle = options.middle end
	if options.bottom then self.bottom = options.bottom end
	self.onPress = options.onPress
	self.style = options.style
end

function boxer.box(options)
	local box = setmetatable({}, Box)
	box:_init(options)
	return box
end

--- text ---

local Text = {}

function Text:getWidth()
	return self.font:getWidth(self.text) * self.scaleX
end

function Text:getHeight()
	return self.font:getHeight() * self.scaleY
end

function Text:setWidth(width)
	self.scaleX = width / self.font:getWidth(self.text)
end

function Text:setHeight(height)
	self.scaleY = height / self.font:getHeight()
end

function Text:draw()
	local style = self:_getStyle()
	love.graphics.setColor(style.color or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, self.x, self.y, 0, self.scaleX, self.scaleY)
end

function Text:__index(k)
	return Text[k] or Box.__index(self, k)
end

Text.__newindex = Box.__newindex

function Text:_init(options)
	assert(options.text)
	assert(options.font)
	self.text = options.text
	self.font = options.font
	self.scaleX = options.scaleX or 1
	self.scaleY = options.scaleY or self.scaleX
	Box._init(self, options, true)
end

function boxer.text(options)
	local text = setmetatable({}, Text)
	text:_init(options)
	return text
end

return boxer
