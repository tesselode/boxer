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

-- returns the number of arguments that evaluate to true
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

-- makes sure that an options table doesn't have more than one horizontal
-- or vertical position property
local function validatePositionOptions(options)
	if count(options.x, options.left, options.center, options.right) > 1 then
		error('Cannot provide more than one horizontal position property', 3)
	end
	if count(options.y, options.top, options.middle, options.bottom) > 1 then
		error('Cannot provide more than one vertical position property', 3)
	end
end

-- creates an instance of a class with some initial state common
-- to every boxer class
local function createInstance(class)
	return setmetatable({
		_hoveredPrevious = false,
		_hovered = false,
		_pressed = false,
	}, class)
end

-- given an options table, sets properties (and defaults) of a box
-- that are common to every boxer class
local function setCommonOptions(box, options)
	box.x, box.y = 0, 0
	if options.x then box.x = options.x end
	if options.left then box.left = options.left end
	if options.center then box.center = options.center end
	if options.right then box.right = options.right end
	if options.y then box.y = options.y end
	if options.top then box.top = options.top end
	if options.middle then box.middle = options.middle end
	if options.bottom then box.bottom = options.bottom end
	box.style = options.style
	box.children = options.children or {}
	box.clipChildren = options.clipChildren
	box.transparent = options.transparent
	box.hidden = options.hidden
	box.disabled = options.disabled
	box.onMove = options.onMove
	box.onDrag = options.onDrag
	box.onEnter = options.onEnter
	box.onLeave = options.onLeave
	box.onClick = options.onClick
	box.onPress = options.onPress
end

local Box = {
	properties = {
		x = {
			get = function(self) return self:getX(0) end,
			set = function(self, v) self:setX(v, 0) end,
		},
		left = {
			get = function(self) return self:getX(0) end,
			set = function(self, v) self:setX(v, 0) end,
		},
		center = {
			get = function(self) return self:getX(.5) end,
			set = function(self, v) self:setX(v, .5) end,
		},
		right = {
			get = function(self) return self:getX(1) end,
			set = function(self, v) self:setX(v, 1) end,
		},
		y = {
			get = function(self) return self:getY(0) end,
			set = function(self, v) self:setY(v, 0) end,
		},
		top = {
			get = function(self) return self:getY(0) end,
			set = function(self, v) self:setY(v, 0) end,
		},
		middle = {
			get = function(self) return self:getY(.5) end,
			set = function(self, v) self:setY(v, .5) end,
		},
		bottom = {
			get = function(self) return self:getY(1) end,
			set = function(self, v) self:setY(v, 1) end,
		},
		width = {},
		height = {},
		clipChildren = {},
		transparent = {},
		hidden = {},
		disabled = {},
	}
}

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

-- gets a child by name
function Box:getChild(name)
	for _, child in ipairs(self.children) do
		if child.name == name then
			return child
		end
	end
	return false
end

-- gets a style property given the box's state
-- (idle/pressed/released)
function Box:getCurrentStyle(property)
	if not (self.style and self.style.idle) then return nil end
	if self._pressed and self.style.pressed and self.style.pressed[property] then
		return get(self.style.pressed[property])
	elseif self._hovered and self.style.hovered and self.style.hovered[property] then
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

--[[
	tells the box about mouse movement. corresponds to love.mousemoved.
	mousemoved events will also be passed to child boxes, and child boxes will
	block other child boxes behind them (unless they're transparent)
]]
function Box:mousemoved(x, y, dx, dy, istouch)
	if self.disabled then return end
	if self.clipChildren and not self:containsPoint(x, y) then
		for _, child in ipairs(self.children) do
			child:_mouseoff()
		end
		self:_mouseoff()
		return
	end
	for i = #self.children, 1, -1 do
		local child = self.children[i]
		child:mousemoved(x - self.x, y - self.y, dx, dy, istouch)
		if not child.transparent and child:containsPoint(x - self.x, y - self.y) then
			for j = i - 1, 1, -1 do
				local lowerChild = self.children[j]
				lowerChild:_mouseoff()
			end
			self:_mouseoff()
			return
		end
	end
	self._hoveredPrevious = self._hovered
	self._hovered = self:containsPoint(x, y)
	if self.onMove and self._hovered then
		self.onMove(x - self.x, y - self.y, dx, dy)
	end
	if self.onDrag and self._pressed then
		self.onDrag(self._pressed, dx, dy)
	end
	if self._hovered and not self._hoveredPrevious and self.onEnter then
		self.onEnter()
	end
	if not self._hovered and self._hoveredPrevious and self.onLeave then
		self.onLeave()
	end
end

--[[
	tells a box that the mouse is no longer hovering it.
	used when a box shouldn't be hovered, but the mouse is technically over it
	(outside of a clipping region, blocked by another box, etc.)
]]
function Box:_mouseoff()
	if self.disabled then return end
	self._hoveredPrevious = self._hovered
	self._hovered = false
	if not self._hovered and self._hoveredPrevious and self.onLeave then
		self.onLeave()
	end
end

--[[
	tells a box that a mouse button was pressed. corresponds to love.mousepressed.
	also tells child boxes about mouse presses
]]
function Box:mousepressed(x, y, button, istouch, presses)
	if self.disabled then return end
	if self.clipChildren and not self:containsPoint(x, y) then
		return
	end
	for i = #self.children, 1, -1 do
		local child = self.children[i]
		if child:containsPoint(x - self.x, y - self.y) then
			child:mousepressed(x - self.x, y - self.y, button, istouch, presses)
			if not child.transparent then return end
		end
	end
	if not self._pressed and self:containsPoint(x, y) then
		self._pressed = button
		if self.onClick then self.onClick(button) end
	end
end

--[[
	tells a box that a mouse button was released. corresponds to love.mousereleased.
	also tells child boxes about mouse releases
]]
function Box:mousereleased(x, y, button, istouch, presses)
	-- mouse releases should trigger regardless of whether the box is hovered or not,
	-- so we don't bother with blocking/clipping checks here
	if self.disabled then return end
	if button == self._pressed then
		self._pressed = false
		if self.onPress and self._hovered then
			self.onPress(button)
		end
	end
	for _, child in ipairs(self.children) do
		child:mousereleased(x, y, button, istouch, presses)
	end
end

--[[
	draws a box with appropriate styling. can be overridden for custom visuals.
	note that drawSelf should be written as if the top-left corner of the box
	is always at 0, 0 (box.draw applies a translation based on the box's position)
]]
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

--[[
	draws the stencil for a box. used for clipping children.
	can be overridden to match a custom drawSelf function.
	note that stencil should be written as if the top-left corner of the box
	is always at 0, 0 (box.draw applies a translation based on the box's position)
]]
function Box:stencil()
	local _, _, width, height = self:getRect()
	love.graphics.rectangle('fill', 0, 0, width, height,
		self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
end

-- "pushes" a stencil onto the "stack". used for nested stencils
function Box:_pushStencil(stencilValue)
	love.graphics.push 'all'
	love.graphics.stencil(function() self:stencil() end, 'increment', 1, true)
	love.graphics.setStencilTest('greater', stencilValue)
end

-- "pops" a stencil from the "stack". used for nested stencils
function Box:_popStencil()
	love.graphics.stencil(function() self:stencil() end, 'decrement', 1, true)
	love.graphics.pop()
end

-- draws the box and its children
function Box:draw(stencilValue)
	if self.hidden then return end
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self:getRect())
	self:drawSelf()
	if self.clipChildren then
		self:_pushStencil(stencilValue)
		for _, child in ipairs(self.children) do
			child:draw(stencilValue + 1)
		end
		self:_popStencil()
	else
		for _, child in ipairs(self.children) do
			child:draw(stencilValue)
		end
	end
	love.graphics.pop()
end

function Box:__index(k)
	if Box.properties[k] then
		if Box.properties[k].get then
			return Box.properties[k].get(self)
		end
		return get(self['_' .. k])
	end
	return Box[k]
end

function Box:__newindex(k, v)
	if Box.properties[k] then
		if Box.properties[k].set then
			Box.properties[k].set(self, v)
		else
			self['_' .. k] = v
		end
	else
		rawset(self, k, v)
	end
end

function boxer.box(options)
	validatePositionOptions(options)
	local box = createInstance(Box)
	box.width = options.width or 0
	box.height = options.height or 0
	setCommonOptions(box, options)
	return box
end

--[[
	creates a box around a number of children and adjusts the children's
	position to be relative to the box.
]]
function boxer.wrap(options)
	if not options then
		error('Must provide an options table to boxer.wrap()', 2)
	end
	if not (options.children and #options.children > 0) then
		error('Must provide at least one child to wrap', 2)
	end
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
			child._y = child._y - top
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

local Text = {}

function Text:drawSelf()
	local r, g, b, a = self:getCurrentStyle 'color'
	if r then
		love.graphics.setColor(r, g, b, a)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, 0, 0, 0, self.scaleX, self.scaleY)
end

function Text:__index(k)
	if k == 'font' then
		return get(self._font)
	elseif k == 'text' then
		return get(self._text)
	elseif k == 'width' then
		return self.font:getWidth(self.text) * self.scaleX
	elseif k == 'height' then
		return self.font:getHeight() * self.scaleY
	elseif k == 'scaleX' then
		return get(self._scaleX)
	elseif k == 'scaleY' then
		return get(self._scaleY)
	elseif Text[k] then
		return Text[k]
	end
	return Box.__index(self, k)
end

function Text:__newindex(k, v)
	if k == 'font' then
		self._font = v
	elseif k == 'text' then
		self._text = v
	elseif k == 'width' then
		self.scaleX = v / self.font:getWidth(self.text)
	elseif k == 'height' then
		self.scaleY = v / self.font:getHeight()
	elseif k == 'scaleX' then
		self._scaleX = v
	elseif k == 'scaleY' then
		self._scaleY = v
	else
		Box.__newindex(self, k, v)
	end
end

function boxer.text(options)
	-- validate options
	if not options.text then
		error('Must provide a text string', 2)
	end
	if not options.font then
		error('Must provide a font', 2)
	end
	if count(options.width, options.scaleX) > 1 then
		error('Cannot provide both width and scaleX', 2)
	end
	if count(options.height, options.scaleY) > 1 then
		error('Cannot provide both height and scaleY', 2)
	end
	validatePositionOptions(options)

	local text = createInstance(Text)
	text.text = options.text
	text.font = options.font
	text.scaleX, text.scaleY = 1, 1
	if options.scaleX then text.scaleX = options.scaleX end
	if options.scaleY then text.scaleY = options.scaleY end
	if options.width then text.width = options.width end
	if options.height then text.height = options.height end
	setCommonOptions(text, options)
	if options.transparent == nil then text.transparent = true end
	return text
end

local Paragraph = {}

function Paragraph:drawSelf()
	local r, g, b, a = self:getCurrentStyle 'color'
	if r then
		love.graphics.setColor(r, g, b, a)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, 0, 0, self.width, self.align)
end

function Paragraph:__index(k)
	if k == 'font' then
		return get(self._font)
	elseif k == 'text' then
		return get(self._text)
	elseif k == 'width' then
		return get(self._width)
	elseif k == 'height' then
		local _, lines = self.font:getWrap(self.text, self.width)
		return #lines * self.font:getHeight() * self.font:getLineHeight()
	elseif k == 'align' then
		return get(self._align)
	elseif Paragraph[k] then
		return Paragraph[k]
	end
	return Box.__index(self, k)
end

function Paragraph:__newindex(k, v)
	if k == 'font' then
		self._font = v
	elseif k == 'text' then
		self._text = v
	elseif k == 'width' then
		self._width = v
	elseif k == 'height' then
		error('Cannot set height of a paragraph directly', 2)
	elseif k == 'align' then
		self._align = v
	else
		Box.__newindex(self, k, v)
	end
end

function boxer.paragraph(options)
	-- validate options
	if not options.text then
		error('Must provide a text string', 2)
	end
	if not options.font then
		error('Must provide a font', 2)
	end
	if not options.width then
		error('Must provide a width', 2)
	end
	if options.height then
		error('Cannot set height of a paragraph directly', 2)
	end
	validatePositionOptions(options)

	local paragraph = createInstance(Paragraph)
	paragraph.text = options.text
	paragraph.font = options.font
	paragraph.width = options.width
	setCommonOptions(paragraph, options)
	if options.transparent == nil then paragraph.transparent = true end
	return paragraph
end

local Image = {}

function Image:drawSelf()
	local r, g, b, a = self:getCurrentStyle 'color'
	if r then
		love.graphics.setColor(r, g, b, a)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.draw(self.image, 0, 0, 0, self.scaleX, self.scaleY)
end

function Image:__index(k)
	if k == 'image' then
		return get(self._image)
	elseif k == 'width' then
		return self.image:getWidth() * self.scaleX
	elseif k == 'height' then
		return self.image:getHeight() * self.scaleY
	elseif k == 'scaleX' then
		return get(self._scaleX)
	elseif k == 'scaleY' then
		return get(self._scaleY)
	elseif Image[k] then
		return Image[k]
	end
	return Box.__index(self, k)
end

function Image:__newindex(k, v)
	if k == 'image' then
		self._image = v
	elseif k == 'width' then
		self.scaleX = v / self.image:getWidth()
	elseif k == 'height' then
		self.scaleY = v / self.image:getHeight()
	elseif k == 'scaleX' then
		self._scaleX = v
	elseif k == 'scaleY' then
		self._scaleY = v
	else
		Box.__newindex(self, k, v)
	end
end

function boxer.image(options)
	-- validate options
	if not options.image then
		error('Must provide an image', 2)
	end
	if count(options.width, options.scaleX) > 1 then
		error('Cannot provide both width and scaleX', 2)
	end
	if count(options.height, options.scaleY) > 1 then
		error('Cannot provide both height and scaleY', 2)
	end
	validatePositionOptions(options)

	local image = createInstance(Image)
	image.image = options.image
	image.scaleX, image.scaleY = 1, 1
	if options.scaleX then image.scaleX = options.scaleX end
	if options.scaleY then image.scaleY = options.scaleY end
	if options.width then image.width = options.width end
	if options.height then image.height = options.height end
	setCommonOptions(image, options)
	return image
end

local Ellipse = {}

function Ellipse:containsPoint(x, y)
	local rx, ry = self.width/2, self.height/2
	return ((x - self.center) ^ 2) / (rx ^ 2) + ((y - self.middle) ^ 2) / (ry ^ 2) <= 1
end

function Ellipse:drawSelf()
	if self:getCurrentStyle 'fillColor' then
		love.graphics.setColor(self:getCurrentStyle 'fillColor')
		love.graphics.ellipse('fill', self.width/2, self.height/2,
			self.width/2, self.height/2, self.segments)
	end
	if self:getCurrentStyle 'outlineColor' then
		love.graphics.setColor(self:getCurrentStyle 'outlineColor')
		love.graphics.setLineWidth(self:getCurrentStyle 'lineWidth' or 1)
		love.graphics.ellipse('line', self.width/2, self.height/2,
			self.width/2, self.height/2, self.segments)
	end
end

function Ellipse:stencil()
	love.graphics.ellipse('fill', self.width/2, self.height/2,
		self.width/2, self.height/2, self.segments)
end

function Ellipse:__index(k)
	if k == 'segments' then
		return get(self._segments)
	elseif Ellipse[k] then
		return Ellipse[k]
	end
	return Box.__index(self, k)
end

function Ellipse:__newindex(k, v)
	if k == 'segments' then
		self._segments = v
	else
		Box.__newindex(self, k, v)
	end
end

function boxer.ellipse(options)
	validatePositionOptions(options)
	local ellipse = createInstance(Ellipse)
	ellipse.width = options.width or 0
	ellipse.height = options.height or 0
	setCommonOptions(ellipse, options)
	return ellipse
end

return boxer
