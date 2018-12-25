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
	if type(value) == 'function' then
		return value()
	else
		return value
	end
end

--- box ---

local Box = {
	properties = {
		x = {
			get = function(self) return self:getX(0) end,
			set = function(self, value) self:setX(value, 0) end,
		},
		left = {
			get = function(self) return self:getX(0) end,
			set = function(self, value) self:setX(value, 0) end,
		},
		center = {
			get = function(self) return self:getX(.5) end,
			set = function(self, value) self:setX(value, .5) end,
		},
		right = {
			get = function(self) return self:getX(1) end,
			set = function(self, value) self:setX(value, 1) end,
		},
		y = {
			get = function(self) return self:getY(0) end,
			set = function(self, value) self:setY(value, 0) end,
		},
		top = {
			get = function(self) return self:getY(0) end,
			set = function(self, value) self:setY(value, 0) end,
		},
		middle = {
			get = function(self) return self:getY(.5) end,
			set = function(self, value) self:setY(value, .5) end,
		},
		bottom = {
			get = function(self) return self:getY(1) end,
			set = function(self, value) self:setY(value, 1) end,
		},
		width = {
			get = function(self) return get(self._width) end,
			set = function(self, value) self._width = value end,
		},
		height = {
			get = function(self) return get(self._height) end,
			set = function(self, value) self._height = value end,
		},
	}
}

function Box:_getCurrentStyle()
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
	local width = self.width
	local x = get(self._x)
	x = x - width * self._anchorX
	return x + width * offset
end

function Box:getY(offset)
	offset = offset or 0
	local height = self.height
	local y = get(self._y)
	y = y - height * self._anchorY
	return y + height * offset
end

function Box:getRect()
	return self.x, self.y, self.width, self.height
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

function Box:mousemoved(x, y, dx, dy, istouch)
	self.hovered = self:containsPoint(x, y)
	for _, child in ipairs(self.children) do
		child:mousemoved(x - self.x, y - self.y, dx, dy, istouch)
	end
end

function Box:mousepressed(x, y, button, istouch, presses)
	if not self.pressed and self.hovered then
		self.pressed = button
	end
	for _, child in ipairs(self.children) do
		child:mousepressed(x - self.x, y - self.y, button, istouch, presses)
	end
end

function Box:mousereleased(x, y, button, istouch, presses)
	if button == self.pressed then
		self.pressed = false
		if self.onPress and self.hovered then
			self.onPress()
		end
	end
	for _, child in ipairs(self.children) do
		child:mousereleased(x - self.x, y - self.y, button, istouch, presses)
	end
end

function Box:drawSelf()
	local _, _, width, height = self:getRect()
	local style = self:_getCurrentStyle()
	if style then
		if get(style.outlineColor) then
			love.graphics.setColor(get(style.outlineColor))
			love.graphics.setLineWidth(get(style.lineWidth) or 1)
			love.graphics.rectangle('line', 0, 0, width, height, get(style.radiusX), get(style.radiusY))
		end
		if style.fillColor then
			love.graphics.setColor(get(style.fillColor))
			love.graphics.rectangle('fill', 0, 0, width, height, get(style.radiusX), get(style.radiusY))
		end
	end
end

function Box:pushStencil(stencilValue)
	love.graphics.push 'all'
	local _, _, width, height = self:getRect()
	local style = self:_getCurrentStyle()
	love.graphics.stencil(function()
		local radiusX = style and style.radiusX
		local radiusY = style and style.radiusY
		love.graphics.rectangle('fill', 0, 0, width, height, radiusX, radiusY)
	end, 'increment', 1, true)
	love.graphics.setStencilTest('greater', stencilValue)
end

function Box:popStencil()
	local _, _, width, height = self:getRect()
	local style = self:_getCurrentStyle()
	love.graphics.stencil(function()
		local radiusX = style and style.radiusX
		local radiusY = style and style.radiusY
		love.graphics.rectangle('fill', 0, 0, width, height, radiusX, radiusY)
	end, 'decrement', 1, true)
	love.graphics.pop()
end

function Box:draw(stencilValue)
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self:getRect())
	self:drawSelf()
	if self.clipChildren then
		self:pushStencil(stencilValue)
		for _, child in ipairs(self.children) do
			child:draw(stencilValue + 1)
		end
		self:popStencil()
	else
		for _, child in ipairs(self.children) do
			child:draw(stencilValue)
		end
	end
	love.graphics.pop()
end

function Box:__index(k)
	if Box.properties[k] and Box.properties[k].get then
		return Box.properties[k].get(self)
	end
	return Box[k]
end

function Box:__newindex(k, v)
	if Box.properties[k] then
		Box.properties[k].set(self, v)
	else
		rawset(self, k, v)
	end
end

function Box:_init(options, sizeIsOptional)
	-- mouse state
	self.hovered = false
	self.pressed = false

	-- options
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
	self.children = options.children or {}
	self.clipChildren = options.clipChildren
end

function boxer.box(options)
	local box = setmetatable({}, Box)
	box:_init(options)
	return box
end

function boxer.wrap(options)
	assert(options)
	assert(options.children and #options.children > 0)
	local padding = options.padding or 0
	local left = options.children[1].left
	local top = options.children[1].top
	local right = options.children[1].right
	local bottom = options.children[1].bottom
	for i = 2, #options.children do
		local child = options.children[i]
		left = math.min(left, child.left)
		top = math.min(top, child.top)
		right = math.max(right, child.right)
		bottom = math.max(bottom, child.bottom)
	end
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	for _, child in ipairs(options.children) do
		if type(child._x) == 'function' then
			local oldX = child._x
			child._x = function() return oldX() - left end
		else
			child._x = child._x - left
		end
		if type(child._y) == 'function' then
			local oldY = child._y
			child._y = function() return oldY() - top end
		else
			child._y = child._y - left
		end
	end
	return boxer.box {
		left = left,
		top = top,
		width = right - left,
		height = bottom - top,
		children = options.children,
	}
end

--- text ---

local Text = {
	properties = {
		font = {
			get = function(self) return get(self._font) end,
			set = function(self, font) self._font = font end,
		},
		text = {
			get = function(self) return get(self._text) end,
			set = function(self, text) self._text = text end,
		},
		scaleX = {
			get = function(self) return get(self._scaleX) end,
			set = function(self, scaleX) self._scaleX = scaleX end,
		},
		scaleY = {
			get = function(self) return get(self._scaleY) end,
			set = function(self, scaleY) self._scaleY = scaleY end,
		},
		width = {
			get = function(self)
				return self.font:getWidth(self.text) * self.scaleX
			end,
			set = function(self, width)
				self.scaleX = width / self.font:getWidth(self.text)
			end,
		},
		height = {
			get = function(self)
				return self.font:getHeight() * self.scaleY
			end,
			set = function(self, height)
				self.scaleY = height / self.font:getHeight()
			end,
		}
	}
}

function Text:draw()
	local style = self:_getCurrentStyle()
	love.graphics.setColor(style and get(style.color) or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, self.x, self.y, 0, self.scaleX, self.scaleY)
end

function Text:__index(k)
	if Text.properties[k] then
		return Text.properties[k].get(self)
	elseif Box.properties[k] then
		return Box.properties[k].get(self)
	elseif Text[k] then
		return Text[k]
	else
		return Box[k]
	end
end

function Text:__newindex(k, v)
	if Text.properties[k] then
		Text.properties[k].set(self, v)
	elseif Box.properties[k] then
		Box.properties[k].set(self, v)
	else
		rawset(self, k, v)
	end
end

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

-- paragraph --

local Paragraph = {
	properties = {
		font = {
			get = function(self) return get(self._font) end,
			set = function(self, font) self._font = font end,
		},
		text = {
			get = function(self) return get(self._text) end,
			set = function(self, text) self._text = text end,
		},
		align = {
			get = function(self) return get(self._align) end,
			set = function(self, align) self._align = align end,
		},
		height = {
			get = function(self)
				local _, lines = self.font:getWrap(self.text, self.width)
				return #lines * self.font:getHeight() * self.font:getLineHeight()
			end,
			set = function(self, height)
				error('Cannot set height of a paragraph directly', 2)
			end,
		}
	}
}

function Paragraph:draw()
	local style = self:_getCurrentStyle()
	love.graphics.setColor(style and get(style.color) or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
end

function Paragraph:__index(k)
	if Paragraph.properties[k] then
		return Paragraph.properties[k].get(self)
	elseif Box.properties[k] then
		return Box.properties[k].get(self)
	elseif Paragraph[k] then
		return Paragraph[k]
	else
		return Box[k]
	end
end

function Paragraph:__newindex(k, v)
	if Paragraph.properties[k] then
		Paragraph.properties[k].set(self, v)
	elseif Box.properties[k] then
		Box.properties[k].set(self, v)
	else
		rawset(self, k, v)
	end
end

function Paragraph:_init(options)
	assert(options.text)
	assert(options.font)
	assert(options.width)
	self.text = options.text
	self.font = options.font
	self.align = options.align
	Box._init(self, options, true)
end

function boxer.paragraph(options)
	local paragraph = setmetatable({}, Paragraph)
	paragraph:_init(options)
	return paragraph
end

--- image ---

local Image = {
	properties = {
		image = {
			get = function(self) return get(self._image) end,
			set = function(self, image) self._image = image end,
		},
		scaleX = {
			get = function(self) return get(self._scaleX) end,
			set = function(self, scaleX) self._scaleX = scaleX end,
		},
		scaleY = {
			get = function(self) return get(self._scaleY) end,
			set = function(self, scaleY) self._scaleY = scaleY end,
		},
		width = {
			get = function(self)
				return self.image:getWidth() * self.scaleX
			end,
			set = function(self, width)
				self.scaleX = width / self.image:getWidth()
			end,
		},
		height = {
			get = function(self)
				return self.image:getHeight() * self.scaleY
			end,
			set = function(self, height)
				self.scaleY = height / self.image:getHeight()
			end,
		},
	}
}

function Image:draw()
	local style = self:_getCurrentStyle()
	love.graphics.setColor(style and get(style.color) or {1, 1, 1})
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY)
end

function Image:__index(k)
	if Image.properties[k] then
		return Image.properties[k].get(self)
	elseif Box.properties[k] then
		return Box.properties[k].get(self)
	elseif Image[k] then
		return Image[k]
	else
		return Box[k]
	end
end

function Image:__newindex(k, v)
	if Image.properties[k] then
		Image.properties[k].set(self, v)
	elseif Box.properties[k] then
		Box.properties[k].set(self, v)
	else
		rawset(self, k, v)
	end
end

function Image:_init(options)
	assert(options.image)
	self.image = options.image
	self.scaleX = options.scaleX or 1
	self.scaleY = options.scaleY or self.scaleX
	Box._init(self, options, true)
end

function boxer.image(options)
	local image = setmetatable({}, Image)
	image:_init(options)
	return image
end

return boxer
