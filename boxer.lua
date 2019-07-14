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
local function get(self, value)
	if type(value) == 'function' then
		return value(self)
	else
		return value
	end
end

-- creates a boxer class
local function createClass(parent)
	local class = {}

	function class.extend() return createClass(class) end

	function class:__index(k)
		if class.properties and class.properties[k] then
			if class.properties[k].get then
				return class.properties[k].get(self)
			end
			return get(self, self['_' .. k])
		end
		if class[k] then return class[k] end
		if parent then return parent.__index(self, k) end
	end

	function class:__newindex(k, v)
		if class.properties and class.properties[k] then
			if class.properties[k].set then
				class.properties[k].set(self, v)
			else
				self['_' .. k] = v
			end
		elseif parent then
			parent.__newindex(self, k, v)
		else
			rawset(self, k, v)
		end
	end

	setmetatable(class, {
		__call = function(self, ...)
			local instance = setmetatable({}, class)
			if instance.new then instance:new(...) end
			return instance
		end,
	})

	return class
end

local Box = createClass()

Box.properties = {
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
	width = {
		get = function(self) return get(self, self._width) or 0 end,
	},
	height = {
		get = function(self) return get(self, self._height) or 0 end,
	},
	clipChildren = {},
	transparent = {},
	hidden = {},
	disabled = {},
}

-- makes sure that an options table doesn't have more than one horizontal
-- or vertical position property
function Box:validatePositionOptions(options)
	if count(options.x, options.left, options.center, options.right) > 1 then
		error('Cannot provide more than one horizontal position property', 3)
	end
	if count(options.y, options.top, options.middle, options.bottom) > 1 then
		error('Cannot provide more than one vertical position property', 3)
	end
end

-- given an options table, sets properties (and defaults) of a box
-- that are common to every boxer class
function Box:setCommonOptions(options)
	if options.x then self.x = options.x end
	if options.left then self.left = options.left end
	if options.center then self.center = options.center end
	if options.right then self.right = options.right end
	if options.y then self.y = options.y end
	if options.top then self.top = options.top end
	if options.middle then self.middle = options.middle end
	if options.bottom then self.bottom = options.bottom end
	self.style = options.style
	self.children = options.children or {}
	self.clipChildren = options.clipChildren
	self.transparent = options.transparent
	self.hidden = options.hidden
	self.disabled = options.disabled
	self.beforeDraw = options.beforeDraw
	self.onMove = options.onMove
	self.onDrag = options.onDrag
	self.onEnter = options.onEnter
	self.onLeave = options.onLeave
	self.onClick = options.onClick
	self.onPress = options.onPress
end

function Box:new(options)
	options = options or {}
	self:validatePositionOptions(options)
	self:setCommonOptions(options)
	self.width = options.width
	self.height = options.height
end

-- gets a position along the x-axis of the box depending on the offset
-- (0 = left, 0.5 = center, 1 = right, etc.)
function Box:getX(offset)
	offset = offset or 0
	local x = get(self, self._x) or 0
	x = x - self.width * (self._anchorX or 0)
	return x + self.width * offset
end

-- gets a position along the y-axis of the box depending on the offset
-- (0 = top, 0.5 = middle, 1 = bottom, etc.)
function Box:getY(offset)
	offset = offset or 0
	local y = get(self, self._y) or 0
	y = y - self.height * (self._anchorY or 0)
	return y + self.height * offset
end

function Box:getBounds()
	return self.left, self.top, self.right, self.bottom
end

function Box:getRectangle()
	return self.x, self.y, self.width, self.height
end

function Box:getChildrenLocalLeft()
	if #self.children == 0 then return 0 end
	local left = self.children[1].left
	for i = 2, #self.children do
		left = math.min(left, self.children[i].left)
	end
	return left
end

function Box:getChildrenLocalRight()
	if #self.children == 0 then return 0 end
	local right = self.children[1].right
	for i = 2, #self.children do
		right = math.max(right, self.children[i].right)
	end
	return right
end

function Box:getChildrenLocalTop()
	if #self.children == 0 then return 0 end
	local top = self.children[1].top
	for i = 2, #self.children do
		top = math.min(top, self.children[i].top)
	end
	return top
end

function Box:getChildrenLocalBottom()
	if #self.children == 0 then return 0 end
	local bottom = self.children[1].bottom
	for i = 2, #self.children do
		bottom = math.max(bottom, self.children[i].bottom)
	end
	return bottom
end

function Box:getChildrenLeft()
	return self:getChildrenLocalLeft() + self.x
end

function Box:getChildrenRight()
	return self:getChildrenLocalRight() + self.x
end

function Box:getChildrenTop()
	return self:getChildrenLocalTop() + self.y
end

function Box:getChildrenBottom()
	return self:getChildrenLocalBottom() + self.y
end

function Box:getChildrenWidth()
	return self:getChildrenLocalRight() - self:getChildrenLocalLeft()
end

function Box:getChildrenHeight()
	return self:getChildrenLocalBottom() - self:getChildrenLocalTop()
end

function Box:getChildrenLocalBounds()
	return self:getChildrenLocalLeft(), self:getChildrenLocalTop(),
		self:getChildrenLocalRight(), self:getChildrenLocalBottom()
end

function Box:getChildrenLocalRectangle()
	return self:getChildrenLocalLeft(), self:getChildrenLocalTop(),
		self:getChildrenWidth(), self:getChildrenHeight()
end

function Box:getChildrenBounds()
	return self:getChildrenLeft(), self:getChildrenTop(),
		self:getChildrenRight(), self:getChildrenBottom()
end

function Box:getChildrenRectangle()
	return self:getChildrenLeft(), self:getChildrenTop(),
		self:getChildrenWidth(), self:getChildrenHeight()
end

-- gets a style property given the box's state
-- (idle/pressed/released)
function Box:getCurrentStyle(property)
	if not self.style then return end
	if self._pressed and self.style.pressed and self.style.pressed[property] then
		return get(self, self.style.pressed[property])
	elseif self._hovered and self.style.hovered and self.style.hovered[property] then
		return get(self, self.style.hovered[property])
	elseif self.style.idle then
		return get(self, self.style.idle[property])
	end
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
	return self
end

--[[
	sets the position of a certain point along the y-axis of the box (defined by anchorY)
	0 = top, 0.5 = middle, 1 = bottom, etc.
	y can be a number or a function that returns a number
]]
function Box:setY(y, anchorY)
	anchorY = anchorY or 0
	self._y, self._anchorY = y, anchorY
	return self
end

function Box:setBounds(left, top, right, bottom)
	self.left = left
	self.top = top
	self.width = right - left
	self.height = bottom - top
	return self
end

function Box:setRectangle(x, y, width, height)
	self.x = x
	self.y = y
	self.width = width
	self.height = height
	return self
end

function Box:shiftChildren(dx, dy)
	for _, child in ipairs(self.children) do
		if type(child._x) == 'function' then
			local oldX = child._x
			child.x = function() return oldX() + dx end
		else
			child.x = child.x + dx
		end
		if type(child._y) == 'function' then
			local oldY = child._y
			child.y = function() return oldY() + dy end
		else
			child.y = child.y + dy
		end
	end
	return self
end

function Box:normalizeChildren()
	self:shiftChildren(-self:getChildrenLocalLeft(), -self:getChildrenLocalTop())
	return self
end

function Box:wrap(mode, padding)
	mode = mode or 'moveBox'
	padding = padding or 0
	if not (mode == 'moveBox' or mode == 'moveChildren') then
		error('mode must be "moveBox" or "moveChildren"')
	end
	if mode == 'moveBox' then
		self:setBounds(self:getChildrenBounds())
		self.left = self.left - padding
		self.top = self.top - padding
	elseif mode == 'moveChildren' then
		self.width, self.height = self:getChildrenWidth(), self:getChildrenHeight()
	end
	self:normalizeChildren()
	self.width = self.width + padding * 2
	self.height = self.height + padding * 2
	self:shiftChildren(padding, padding)
	return self
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
		self:onMove(x - self.x, y - self.y, dx, dy)
	end
	if self.onDrag and self._pressed then
		self:onDrag(self._pressed, x - self.x, y - self.y, dx, dy)
	end
	if self._hovered and not self._hoveredPrevious and self.onEnter then
		self:onEnter()
	end
	if not self._hovered and self._hoveredPrevious and self.onLeave then
		self:onLeave()
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
		self:onLeave()
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
		if self.onClick then self:onClick(button) end
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
			self:onPress(button)
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
	if self:getCurrentStyle 'fillColor' then
		love.graphics.setColor(self:getCurrentStyle 'fillColor')
		love.graphics.rectangle('fill', 0, 0, self.width, self.height,
		self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
	end
	if self:getCurrentStyle 'outlineColor' then
		love.graphics.setColor(self:getCurrentStyle 'outlineColor')
		love.graphics.setLineWidth(self:getCurrentStyle 'lineWidth' or 1)
		love.graphics.rectangle('line', 0, 0, self.width, self.height,
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
	love.graphics.rectangle('fill', 0, 0, self.width, self.height,
		self:getCurrentStyle 'radiusX', self:getCurrentStyle 'radiusY')
end

-- "pushes" a stencil onto the "stack". used for nested stencils
function Box:_pushStencil(stencilValue)
	love.graphics.push 'all'
	love.graphics.stencil(self.stencilFunction, 'increment', 1, true)
	love.graphics.setStencilTest('greater', stencilValue)
end

-- "pops" a stencil from the "stack". used for nested stencils
function Box:_popStencil()
	love.graphics.stencil(self.stencilFunction, 'decrement', 1, true)
	love.graphics.pop()
end

-- draws the box and its children
function Box:draw(stencilValue)
	if self.hidden then return end
	if self.beforeDraw then self:beforeDraw() end
	stencilValue = stencilValue or 0
	love.graphics.push 'all'
	love.graphics.translate(self.x, self.y)
	self:drawSelf()
	if self.clipChildren then
		-- cache the stencil function so we don't have to create it every frame
		self.stencilFunction = self.stencilFunction or function()
			self:stencil()
		end
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

boxer.Box = Box

local Text = Box.extend()

Text.properties = {
	font = {},
	text = {},
	width = {
		get = function(self)
			if not self.text then return 0 end
			return self.font:getWidth(self.text) * self.scaleX
		end,
		set = function(self, v)
			self.scaleX = v / self.font:getWidth(self.text)
		end,
	},
	height = {
		get = function(self)
			if not self.text then return 0 end
			return self.font:getHeight() * self.scaleY
		end,
		set = function(self, v)
			self.scaleY = v / self.font:getHeight()
		end,
	},
	scaleX = {},
	scaleY = {},
}

function Text:drawSelf()
	if not self.text then return end
	love.graphics.setFont(self.font)
	if self:getCurrentStyle 'shadowColor' then
		love.graphics.setColor(self:getCurrentStyle 'shadowColor')
		love.graphics.print(
			self.text,
			self:getCurrentStyle 'shadowOffsetX' or 1,
			self:getCurrentStyle 'shadowOffsetY' or 1,
			0,
			self.scaleX,
			self.scaleY
		)
	end
	if self:getCurrentStyle 'color' then
		love.graphics.setColor(self:getCurrentStyle 'color')
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.print(self.text, 0, 0, 0, self.scaleX, self.scaleY)
end

function Text:new(options)
	-- validate options
	if not options then
		error('Must provide an options table', 2)
	end
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
	self:validatePositionOptions(options)

	self.text = options.text
	self.font = options.font
	self.scaleX, self.scaleY = 1, 1
	if options.scaleX then self.scaleX = options.scaleX end
	if options.scaleY then self.scaleY = options.scaleY end
	if options.width then self.width = options.width end
	if options.height then self.height = options.height end
	self:setCommonOptions(options)
	if options.transparent == nil then self.transparent = true end
end

boxer.Text = Text

local Paragraph = Box.extend()

Paragraph.properties = {
	font = {},
	text = {},
	width = {},
	height = {
		get = function(self)
			if not self.text then return 0 end
			local _, lines = self.font:getWrap(self.text, self.width)
			return #lines * self.font:getHeight() * self.font:getLineHeight()
		end,
		set = function(self, v)
			error('Cannot set height of a paragraph directly', 2)
		end,
	},
	align = {},
}

function Paragraph:drawSelf()
	if not self.text then return end
	love.graphics.setFont(self.font)
	if self:getCurrentStyle 'shadowColor' then
		love.graphics.setColor(self:getCurrentStyle 'shadowColor')
		love.graphics.print(
			self.text,
			self:getCurrentStyle 'shadowOffsetX' or 1,
			self:getCurrentStyle 'shadowOffsetY' or 1,
			self.width,
			self.align
		)
	end
	if self:getCurrentStyle 'color' then
		love.graphics.setColor(self:getCurrentStyle 'color')
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.printf(self.text, 0, 0, self.width, self.align)
end

function Paragraph:new(options)
	-- validate options
	if not options then
		error('Must provide an options table', 2)
	end
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
	self:validatePositionOptions(options)

	self.text = options.text
	self.font = options.font
	self.width = options.width
	self:setCommonOptions(options)
	if options.transparent == nil then self.transparent = true end
end

boxer.Paragraph = Paragraph

local Image = Box.extend()

Image.properties = {
	image = {},
	width = {
		get = function(self)
			if not self.image then return 0 end
			return self.image:getWidth() * self.scaleX
		end,
		set = function(self, v)
			self.scaleX = v / self.image:getWidth()
		end,
	},
	height = {
		get = function(self)
			if not self.image then return 0 end
			return self.image:getHeight() * self.scaleY
		end,
		set = function(self, v)
			self.scaleY = v / self.image:getHeight()
		end,
	},
	scaleX = {},
	scaleY = {},
}

function Image:drawSelf()
	if not self.image then return end
	local r, g, b, a = self:getCurrentStyle 'color'
	if r then
		love.graphics.setColor(r, g, b, a)
	else
		love.graphics.setColor(1, 1, 1)
	end
	love.graphics.draw(self.image, 0, 0, 0, self.scaleX, self.scaleY)
end

function Image:new(options)
	-- validate options
	if not options then
		error('Must provide an options table', 2)
	end
	if not options.image then
		error('Must provide an image', 2)
	end
	if count(options.width, options.scaleX) > 1 then
		error('Cannot provide both width and scaleX', 2)
	end
	if count(options.height, options.scaleY) > 1 then
		error('Cannot provide both height and scaleY', 2)
	end
	self:validatePositionOptions(options)

	self.image = options.image
	self.scaleX, self.scaleY = 1, 1
	if options.scaleX then self.scaleX = options.scaleX end
	if options.scaleY then self.scaleY = options.scaleY end
	if options.width then self.width = options.width end
	if options.height then self.height = options.height end
	self:setCommonOptions(options)
end

boxer.Image = Image

local Ellipse = Box.extend()

Ellipse.properties = {
	segments = {},
}

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

boxer.Ellipse = Ellipse

return boxer
