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
		if type(t2) == 'table' then
			for k, v in pairs(t2) do
				t[k] = v
			end
		end
	end
	return t
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

--[[
	gets an instance property. looks for a property.get function. if that's not found,
	defaults to getting self._propertyName.
]]
local function getProperty(self, property, propertyName)
	if type(property) == 'table' and property.get then
		return property.get(self)
	else
		return get(self['_' .. propertyName])
	end
end

--[[
	sets an instance property. looks for a property.set function. if that's not found,
	defaults to setting self._propertyName.
]]
local function setProperty(self, property, propertyName, value)
	if type(property) == 'table' and property.set then
		property.set(self, value)
	else
		self['_' .. propertyName] = value
	end
end

-- gets the metamethods of a class, given the class table and an optional parent
local function getMetamethods(class, parent)
	local function __index(self, k)
		if class.properties[k] then
			return getProperty(self, class.properties[k], k)
		elseif parent and parent.properties[k] then
			return getProperty(self, parent.properties[k], k)
		elseif class[k] then
			return class[k]
		elseif parent then
			return parent[k]
		end
	end
	local function __newindex(self, k, v)
		if class.properties[k] then
			setProperty(self, class.properties[k], k, v)
		elseif parent and parent.properties[k] then
			setProperty(self, parent.properties[k], k, v)
		else
			rawset(self, k, v)
		end
	end
	return __index, __newindex
end

--[[
	--- Boxes ---
	The basic box class. Handles a bunch of cool stuff, like:
	- getting/setting positions with metatable magic ✨
	- mouse events
	- getting styles
	- drawing rectangles (wow!)
]]

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
		width = true,
		height = true,
		clipChildren = true,
		transparent = true,
	}
}

-- gets the style that should be used for drawing given the box's state
-- (idle/pressed/released)
function Box:_getCurrentStyle()
	if not (self.style and self.style.idle) then return nil end
	local style = merge(
		self.style.idle,
		self.hovered and self.style.hovered,
		self.pressed and self.style.pressed
	)
	for k, v in pairs(style) do style[k] = get(v) end
	return style
end

-- gets a position along the x-axis of the box depending on the offset
-- (0 = left, 0.5 = center, 1 = right, etc.)
function Box:getX(offset)
	offset = offset or 0
	local width = self.width
	local x = get(self._x)
	x = x - width * self._anchorX
	return x + width * offset
end

-- gets a position along the y-axis of the box depending on the offset
-- (0 = top, 0.5 = middle, 1 = bottom, etc.)
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

--[[
	returns whether the box overlaps with another box
	can take either left, top, right, bottom arguments
	or a single table with x, y, width, and height properties
	(can be another boxer Box or just whatever table)
]]
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

--[[
	tells the box about mouse movement. corresponds to love.mousemoved
	mousemoved events will also be passed to child boxes, and child boxes will
	block other child boxes behind them (unless they're transparent)
]]
function Box:mousemoved(x, y, dx, dy, istouch)
	self.hovered = self:containsPoint(x, y)
	for i = #self.children, 1, -1 do
		local child = self.children[i]
		local mouseClipped = self.clipChildren and not self.hovered
		if mouseClipped then
			child:mouseoff()
		else
			child:mousemoved(x - self.x, y - self.y, dx, dy, istouch)
			if not child.transparent and child:containsPoint(x - self.x, y - self.y) then
				for j = i - 1, 1, -1 do
					local lowerChild = self.children[j]
					lowerChild:mouseoff()
				end
				self.hovered = false
				return
			end
		end
	end
end

--[[
	tells a box that the mouse is no longer hovering it.
	used when a box shouldn't be hovered, but the mouse is technically over it
	(outside of a clipping region, blocked by another box, etc.)
]]
function Box:mouseoff()
	self.hovered = false
end

--[[
	tells a box that a mouse button was pressed. corresponds to love.mousepressed
	also tells child boxes about mouse presses, but doesn't consider clipping/blocking (yet)
]]
function Box:mousepressed(x, y, button, istouch, presses)
	if not self.pressed and self.hovered then
		self.pressed = button
	end
	for _, child in ipairs(self.children) do
		child:mousepressed(x - self.x, y - self.y, button, istouch, presses)
	end
end

--[[
	tells a box that a mouse button was released. corresponds to love.mousereleased
	also tells child boxes about mouse releases, but doesn't consider clipping/blocking (yet)
]]
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

-- draws the box's fill/outline
function Box:drawSelf()
	local _, _, width, height = self:getRect()
	local style = self:_getCurrentStyle()
	if style then
		if style.outlineColor then
			love.graphics.setColor(style.outlineColor)
			love.graphics.setLineWidth(style.lineWidth or 1)
			love.graphics.rectangle('line', 0, 0, width, height, style.radiusX, style.radiusY)
		end
		if style.fillColor then
			love.graphics.setColor(style.fillColor)
			love.graphics.rectangle('fill', 0, 0, width, height, style.radiusX, style.radiusY)
		end
	end
end

-- "pushes" a stencil onto the "stack". used for nested stencils
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

-- "pops" a stencil from the "stack". used for nested stencils
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

-- draws the box and its children
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

Box.__index, Box.__newindex = getMetamethods(Box)

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
	self.transparent = options.transparent
end

function boxer.box(options)
	local box = setmetatable({}, Box)
	box:_init(options)
	return box
end

--[[
	creates a box around a number of children and adjusts the children's
	position to be relative to the box.
]]
function boxer.wrap(options)
	assert(options)
	assert(options.children and #options.children > 0)
	local padding = options.padding or 0
	-- get the bounds of the box
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
	-- add padding
	left = left - padding
	top = top - padding
	right = right + padding
	bottom = bottom + padding
	-- adjust child positions
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
	-- return the box
	return boxer.box {
		left = left,
		top = top,
		width = right - left,
		height = bottom - top,
		children = options.children,
	}
end

--[[
	--- Text ---
	Draws text, as you might expect. The behavior differs from regular boxes
	in that the width and height are products of the font, text string,
	scaleX, and scaleY. Setting the width or height will change scaleX
	and scaleY, respectively.
]]

local Text = {
	properties = {
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
		},
		font = true,
		text = true,
		scaleX = true,
		scaleY = true,
	}
}

function Text:draw()
	local style = self:_getCurrentStyle()
	love.graphics.setColor(style and style.color or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, self.x, self.y, 0, self.scaleX, self.scaleY)
end

Text.__index, Text.__newindex = getMetamethods(Text, Box)

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

--[[
	--- Paragraphs ---
	Similar to the Text class, but uses the width property to define
	how text should wrap. Height is readonly and determined from
	the number of lines the text uses.
]]

local Paragraph = {
	properties = {
		height = {
			get = function(self)
				local _, lines = self.font:getWrap(self.text, self.width)
				return #lines * self.font:getHeight() * self.font:getLineHeight()
			end,
			set = function(self, height)
				error('Cannot set height of a paragraph directly', 2)
			end,
		},
		font = true,
		text = true,
		align = true,
	}
}

function Paragraph:draw()
	local style = self:_getCurrentStyle()
	love.graphics.setColor(style and style.color or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
end

Paragraph.__index, Paragraph.__newindex = getMetamethods(Paragraph, Box)

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

--[[
	--- Images ---
	Draws an image. The image is stretched to fill the defined
	width and height. Width and height can also be defined using
	scaleX and scaleY.
]]

local Image = {
	properties = {
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
		image = true,
		scaleX = true,
		scaleY = true,
	}
}

function Image:draw()
	local style = self:_getCurrentStyle()
	love.graphics.setColor(style and style.color or {1, 1, 1})
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY)
end

Image.__index, Image.__newindex = getMetamethods(Image, Box)

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
