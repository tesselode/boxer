local boxer = {
	_VERSION = 'Boxer',
	_DESCRIPTION = 'Layout library for LÖVE.',
	_URL = 'https://github.com/tesselode/boxer',
	_LICENSE = [[
		MIT License

		Copyright (c) 2018 Andrew Minnich

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

--- utilities ---

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

local function getType(value)
	return type(value) == 'userdata' and value:type() or type(value)
end

local function isCompatibleType(property, value)
	local t = getType(value)
	if property.mode == 'dynamic' and t == 'function' then
		return isCompatibleType(property, value())
	end
	if property.type == 'boolean' and t == 'nil' then
		return true
	end
	if t == 'nil' and not property.required then
		return true
	end
	if not property.type then return true end
	return t == property.type
end

-- boxer.Class
local function newClass(parent)
	local class = {properties = {}}

	function class:extend() return newClass(self) end

	function class:_getProperty(propertyName)
		local property = class.properties[propertyName]
		assert(property, 'no property named ' .. propertyName .. ' exists')
		assert(type(property) == 'table', 'property definitions must be tables')
		if property.alias then
			return self[property.alias]
		elseif property.mode == 'dynamic' then
			return get(self['_' .. propertyName])
		elseif property.mode == 'normal' then
			return self['_' .. propertyName]
		elseif property.get then
			return property.get(self)
		end
	end

	function class:_setProperty(propertyName, value)
		local property = class.properties[propertyName]
		assert(property, 'no property named ' .. propertyName .. ' exists')
		assert(type(property) == 'table', 'property definitions must be tables')
		if property.readonly then
			error(propertyName .. ' is a readonly value', 3)
		end
		if property.alias then
			self[property.alias] = value
		elseif property.mode == 'dynamic' then
			if not isCompatibleType(property, value) then
				error(propertyName .. ' must be a ' .. property.type
					.. ' or a function that returns a ' .. property.type
					.. ' (got ' .. getType(value) .. ') ', 5)
			end
			self['_' .. propertyName] = value
		elseif property.mode == 'normal' then
			if not isCompatibleType(property, value) then
				error(propertyName .. ' must be a ' .. property.type
					.. ' (got ' .. getType(value) .. ') ', 5)
			end
			self['_' .. propertyName] = value
		elseif property.set then
			property.set(self, value)
		end
	end

	function class:_initProperties(initialized)
		initialized = initialized or {}
		for propertyName, property in pairs(class.properties) do
			if not initialized[propertyName] then
				if property.default then
					self[propertyName] = property.default
				end
				initialized[propertyName] = true
			end
		end
		if parent then parent._initProperties(self, initialized) end
	end

	function class:_checkProperties(checked)
		checked = checked or {}
		for propertyName, property in pairs(class.properties) do
			if not checked[propertyName] then
				if property.required and not self[propertyName] then
					error(propertyName .. ' is a required property', 3)
				end
				checked[propertyName] = true
			end
		end
		if parent then parent._checkProperties(self, checked) end
	end

	function class:__index(k)
		if class[k] then
			return class[k]
		elseif class.properties[k] then
			return class._getProperty(self, k)
		elseif parent then
			return parent.__index(self, k)
		end
	end

	function class:__newindex(k, v)
		if class.properties[k] then
			class._setProperty(self, k, v)
		elseif parent then
			parent.__newindex(self, k, v)
		else
			rawset(self, k, v)
		end
	end

	setmetatable(class, {
		__call = function(self, ...)
			local instance = setmetatable({}, class)
			instance:_initProperties()
			if instance.new then instance:new(...) end
			instance:_checkProperties()
			return instance
		end,
	})

	return class
end

boxer.Class = newClass

--[[
	--- Boxes ---
	The basic box class. Handles a bunch of cool stuff, like:
	- getting/setting positions with metatable magic ✨
	- mouse events
	- getting styles
	- drawing rectangles (wow!)
]]

local Box = newClass()

Box.properties = {
	x = {
		get = function(self) return self:getX(0) end,
		set = function(self, value) self:setX(value, 0) end,
		type = 'number',
		default = 0,
	},
	left = {alias = 'x'},
	center = {
		get = function(self) return self:getX(.5) end,
		set = function(self, value) self:setX(value, .5) end,
		type = 'number',
	},
	right = {
		get = function(self) return self:getX(1) end,
		set = function(self, value) self:setX(value, 1) end,
		type = 'number',
	},
	y = {
		get = function(self) return self:getY(0) end,
		set = function(self, value) self:setY(value, 0) end,
		type = 'number',
		default = 0,
	},
	top = {alias = 'y'},
	middle = {
		get = function(self) return self:getY(.5) end,
		set = function(self, value) self:setY(value, .5) end,
		type = 'number',
	},
	bottom = {
		get = function(self) return self:getY(1) end,
		set = function(self, value) self:setY(value, 1) end,
		type = 'number',
	},
	width = {mode = 'dynamic', type = 'number', required = true},
	height = {mode = 'dynamic', type = 'number', required = true},
	w = {alias = 'width'},
	h = {alias = 'height'},
	name = {mode = 'dynamic', type = 'string'},
	style = {mode = 'dynamic', type = 'table'},
	children = {mode = 'dynamic', type = 'table', default = {}},
	clipChildren = {mode = 'dynamic', type = 'boolean'},
	transparent = {mode = 'dynamic', type = 'boolean'},
	hidden = {mode = 'dynamic', type = 'boolean'},
	disabled = {mode = 'dynamic', type = 'boolean'},
	onPress = {mode = 'normal', type = 'function'},
	onClick = {mode = 'normal', type = 'function'},
	onEnter = {mode = 'normal', type = 'function'},
	onLeave = {mode = 'normal', type = 'function'},
	onMove = {mode = 'normal', type = 'function'},
	onDrag = {mode = 'normal', type = 'function'},
	hovered = {mode = 'normal', type = 'boolean', readonly = true},
	pressed = {mode = 'normal', type = 'boolean', readonly = true},
}

-- gets a style property given the box's state
-- (idle/pressed/released)
function Box:getCurrentStyle(property)
	if not (self.style and self.style.idle) then return nil end
	return self._pressed and self.style.pressed and get(self.style.pressed[property])
		or self._hovered and self.style.hovered and get(self.style.hovered[property])
		or get(self.style.idle[property])
end

-- gets a position along the x-axis of the box depending on the offset
-- (0 = left, 0.5 = center, 1 = right, etc.)
function Box:getX(offset)
	offset = offset or 0
	local width = self.width or 0
	local x = get(self._x)
	x = x - width * self._anchorX
	return x + width * offset
end

-- gets a position along the y-axis of the box depending on the offset
-- (0 = top, 0.5 = middle, 1 = bottom, etc.)
function Box:getY(offset)
	offset = offset or 0
	local height = self.height or 0
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
	tells a box that a mouse button was pressed. corresponds to love.mousepressed
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
	tells a box that a mouse button was released. corresponds to love.mousereleased
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

function Box:drawSelf()
	local _, _, width, height = self:getRect()
	if self:getCurrentStyle 'outlineColor' then
		love.graphics.setColor(self:getCurrentStyle 'outlineColor')
		love.graphics.setLineWidth(self:getCurrentStyle 'lineWidth' or 1)
		love.graphics.rectangle('line', 0, 0, width, height,
			self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
	end
	if self:getCurrentStyle 'fillColor' then
		love.graphics.setColor(self:getCurrentStyle 'fillColor')
		love.graphics.rectangle('fill', 0, 0, width, height,
			self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
	end
end

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

local childrenMetatable = {
	__index = function(self, k)
		for _, child in ipairs(self) do
			if child.name == k then return child end
		end
	end,
}

function Box:init()
	self._hoveredPrevious = false
	self._hovered = false
	self._pressed = false
	setmetatable(self.children, childrenMetatable)
end

function Box:new(options)
	if not options then
		error('Must provide an options table to boxer.Box()', 3)
	end
	if count(options.x, options.left, options.center, options.right) > 1 then
		error('Cannot provide more than one horizontal position property', 3)
	end
	if count(options.y, options.top, options.middle, options.bottom) > 1 then
		error('Cannot provide more than one vertical position property', 3)
	end
	for k, v in pairs(options) do
		if not Box.properties[k] then
			error(k .. ' is not a valid property for boxes', 3)
		end
		self[k] = v
	end
	self:init()
end

boxer.Box = Box

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

local Text = Box:extend()

Text.properties = {
	width = {
		get = function(self)
			return self.font:getWidth(self.text) * self.scaleX
		end,
		set = function(self, width)
			self.scaleX = width / self.font:getWidth(self.text)
		end,
		type = 'number',
	},
	height = {
		get = function(self)
			return self.font:getHeight() * self.scaleY
		end,
		set = function(self, height)
			self.scaleY = height / self.font:getHeight()
		end,
		type = 'number',
	},
	font = {mode = 'dynamic', type = 'Font', required = true},
	text = {mode = 'dynamic', type = 'string', required = true},
	scaleX = {mode = 'dynamic', type = 'number', default = 1},
	scaleY = {mode = 'dynamic', type = 'number', default = 1},
	transparent = {mode = 'dynamic', type = 'boolean', default = true},
}

function Text:drawSelf()
	love.graphics.setColor(self:getCurrentStyle 'color' or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.print(self.text, self.x, self.y, 0, self.scaleX, self.scaleY)
end

function Text:new(options)
	if not options then
		error('Must provide an options table to boxer.Text()', 3)
	end
	if count(options.x, options.left, options.center, options.right) > 1 then
		error('Cannot provide more than one horizontal position property', 3)
	end
	if count(options.y, options.top, options.middle, options.bottom) > 1 then
		error('Cannot provide more than one vertical position property', 3)
	end
	for k, v in pairs(options) do
		if not (Text.properties[k] or Box.properties[k]) then
			error(k .. ' is not a valid property for text', 3)
		end
		self[k] = v
	end
	self:init()
end

boxer.Text = Text

--[[
	--- Paragraphs ---
	Similar to the Text class, but uses the width property to define
	how text should wrap. Height is readonly and determined from
	the number of lines the text uses.
]]

local Paragraph = Box:extend()

Paragraph.properties = {
	height = {
		get = function(self)
			local _, lines = self.font:getWrap(self.text, self.width)
			return #lines * self.font:getHeight() * self.font:getLineHeight()
		end,
		set = function(self, height)
			error('Cannot set height of a paragraph directly', 2)
		end,
		type = 'number',
	},
	font = {mode = 'dynamic', type = 'Font', required = true},
	text = {mode = 'dynamic', type = 'string', required = true},
	align = {mode = 'dynamic', type = 'string'},
}

function Paragraph:drawSelf()
	love.graphics.setColor(self:getCurrentStyle 'color' or {1, 1, 1})
	love.graphics.setFont(self.font)
	love.graphics.printf(self.text, self.x, self.y, self.width, self.align)
end

function Paragraph:new(options)
	if not options then
		error('Must provide an options table to boxer.Paragraph()', 3)
	end
	if count(options.x, options.left, options.center, options.right) > 1 then
		error('Cannot provide more than one horizontal position property', 3)
	end
	if count(options.y, options.top, options.middle, options.bottom) > 1 then
		error('Cannot provide more than one vertical position property', 3)
	end
	for k, v in pairs(options) do
		if not (Paragraph.properties[k] or Box.properties[k]) then
			error(k .. ' is not a valid property for paragraphs', 3)
		end
		self[k] = v
	end
	self:init()
end

--[[
	--- Images ---
	Draws an image. The image is stretched to fill the defined
	width and height. Width and height can also be defined using
	scaleX and scaleY.
]]

local Image = Box:extend()

Image.properties = {
	width = {
		get = function(self)
			return self.image:getWidth() * self.scaleX
		end,
		set = function(self, width)
			self.scaleX = width / self.image:getWidth()
		end,
		type = 'number',
	},
	height = {
		get = function(self)
			return self.image:getHeight() * self.scaleY
		end,
		set = function(self, height)
			self.scaleY = height / self.image:getHeight()
		end,
		type = 'number',
	},
	image = {mode = 'dynamic', type = 'Image', required = true},
	scaleX = {mode = 'dynamic', type = 'number', default = 1},
	scaleY = {mode = 'dynamic', type = 'number', default = 1},
}

function Image:drawSelf()
	love.graphics.setColor(self:getCurrentStyle 'color' or {1, 1, 1})
	love.graphics.draw(self.image, self.x, self.y, 0, self.scaleX, self.scaleY)
end

function Image:new(options)
	if not options then
		error('Must provide an options table to boxer.Image()', 3)
	end
	if count(options.x, options.left, options.center, options.right) > 1 then
		error('Cannot provide more than one horizontal position property', 3)
	end
	if count(options.y, options.top, options.middle, options.bottom) > 1 then
		error('Cannot provide more than one vertical position property', 3)
	end
	for k, v in pairs(options) do
		if not (Image.properties[k] or Box.properties[k]) then
			error(k .. ' is not a valid property for images', 3)
		end
		self[k] = v
	end
	self:init()
end

boxer.Image = Image

return boxer
