Boxer
=====

**Boxer** is a library for arranging and drawing graphics in LÖVE. It also handles mouse events, making it a good base for UI work.

Table of contents
-----------------
- [Installation](#installation)
- [Usage](#usage)
	- [Creating boxes](#creating-boxes)
	- [Positioning boxes](#positioning-boxes)
	- [Mouse events](#mouse-events)
	- [Drawing boxes](#drawing-boxes)
	- [Children](#children)
	- [Images](#images)
	- [Text](#text)
- [API](#api)
	- [Box](#box)
	- [Text](#text)
	- [Paragraph](#paragraph)
	- [Image](#image)
- [Contributing](#contributing)
- [License](#license)

Installation
------------
To use Boxer, place boxer.lua in your project, and then `require` it in each file where you need to use it:

```lua
local boxer = require 'boxer' -- if your boxer.lua is in the root directory
local boxer = require 'path.to.boxer' -- if it's in subfolders
```

Usage
-----

### Creating boxes

A box is the basic object that Boxer creates. To create a box, use `boxer.Box`:

```lua
local box = boxer.Box {
	x = 500,
	bottom = 300,
	width = 50,
	height = 75,
}
```

Usually, you'll want to specify a horizontal position property (`x`, `left`, `center`, or `right`), a vertical position property (`y`, `top`, `middle`, or `bottom`), a `width`, and a `height`. You can also set any other valid `Box` property (see the [Box API](#box) for more details).

If you don't specify a position and size, or if you call `boxer.box` with no arguments, `x`, `y`, `width`, and `height` will all default to 0.

### Positioning boxes

The easiest way to position boxes is to set the position properties. For example, this code will shift a box horizontally so its right edge is lined up with another box's left edge:

```lua
box2.right = box1.left
```

If you need more control, you can use `getX` and `getY` to get the position of an arbitrary point along the x or y axis of a box:

```lua
local x = box:getX(2/3) -- gets the x coordinate 2/3rds of the way between the left and right side of the box
local y = box:getY(.5) -- gets the y coordinate of the vertical center of the box
```

Similarly, you can use `setX` and `setY` to set the position of a box with an arbitrary anchor point:

```lua
box1:setX(box2:getX(.5), 1) -- sets the right edge of box1 to the horizontal center of box2
```

When you set a position, the anchor point is remembered, so that changing the width or height of the box will not affect the position you set.

```lua
box1:setX(box2:getX(.5), 1) -- sets the right edge of box1 to the horizontal center of box2
box1.width = box1.width + 100
-- the right edge of box1 will still be at the horizontal center of box2
```

### Dynamic properties

You can set many box properties to a function, and the property will be automatically updated to the function's return value. For example, this code will keep a box's bottom edge aligned with the bottom of the window, even if the window is resized:

```lua
box.bottom = function()
	return love.graphics.getHeight()
end
```

Property functions will receive the box as the first argument, so you can access properties of the box within the function. This code will set a box's vertical position to be the same as its horizontal position:

```lua
box.y = function(self)
	return self.x
end
```

### Mouse events

Boxes can handle various kinds of mouse events, but first they need to be hooked up to some of LÖVE's mouse callbacks:

```lua
function love.mousemoved(x, y, dx, dy, istouch)
	box:mousemoved(x, y, dx, dy, istouch)
end

function love.mousepressed(x, y, button, istouch, presses)
	box:mousepressed(x, y, button, istouch, presses)
end

function love.mousereleased(x, y, button, istouch, presses)
	box:mousereleased(x, y, button, istouch, presses)
end
```

Once that's done, we can define some callbacks on the box:

```lua
function box.onPress(button)
	if button == 1 then
		print 'hi!'
	end
end

function box.onEnter()
	print "i'm hovered now!"
end
```

The full list of callbacks is in the [API](#box).

### Drawing boxes

Boxes don't have any visual representation by default, but we can add some using the style system. Let's say we want the box to be dark gray with a white outline. We can implement that like this:

```lua
box.style = {
	idle = {
		fillColor = {.2, .2, .2},
		outlineColor = {1, 1, 1},
	},
}
```

The `idle` style is for when the box isn't hovered or pressed. The `idle` style is required, but we can also define `hovered` and `pressed` styles which will be applied on top of the `idle` styles when the box is hovered or pressed. This code will make the button light up slightly when it's hovered, and light up a little less when it's pressed:

```lua
box.style = {
	idle = {
		fillColor = {.2, .2, .2},
		outlineColor = {1, 1, 1},
	},
	hovered = {
		fillColor = {.4, .4, .4},
	},
	pressed = {
		fillColor = {.3, .3, .3},
	},
}
```

Like with other properties, the style properties can be functions:

```lua
box.style = {
	idle = {
		fillColor = function()
			if love.keyboard.isDown 'space' then
				return .5, .5, .5
			else
				return .2, .2, .2
			end
		end,
	}
}
```

See the [Box API](#box) for the full list of style properties.

### Children

Boxes can act as containers for other boxes. To add a box as a child box, insert children into the `box.children` table:

```lua
table.insert(box.children, boxer.box {
	...
})
```

Boxes will pass mouse and draw events to their child boxes. Children later in the `box.children` list will be considered "higher up" than children earlier in the list. Children will block mouse events from reaching lower children, as well as the parent box, which is considered to be lower than all the children.

In this example, there are two child boxes with the same size and position, but clicking them will only print "hi!".

```lua
local parent = boxer.box {
	x = 0,
	y = 0,
	width = 500,
	height = 500,
	children = {
		boxer.box {
			x = 50,
			y = 50,
			width = 50,
			height = 50,
			onPress = function() print 'hello' end,
		},
		boxer.box {
			x = 50,
			y = 50,
			width = 50,
			height = 50,
			onPress = function() print 'hi!' end,
		},
	}
}
```

This is because the box on top is blocking mouse events from reaching the box on bottom. If you want to allow mouse events to pass through a child box, you can set that box's `transparent` property to true.

```lua
local parent = boxer.box {
	x = 0,
	y = 0,
	width = 500,
	height = 500,
	children = {
		boxer.box {
			x = 50,
			y = 50,
			width = 50,
			height = 50,
			onPress = function() print 'hello' end,
		},
		boxer.box {
			x = 50,
			y = 50,
			width = 50,
			height = 50,
			onPress = function() print 'hi!' end,
			transparent = true,
		},
	}
}
-- now clicking within (50, 50) and (100, 100) will print both 'hi!' and 'hello'
```

You can also "wrap" multiple boxes in a parent box that will automatically set its bounds to perfectly contain all of the children using `boxer.wrap`:

```lua
local container = boxer.wrap {
	children = {
		boxer.box {x = 50, y = 50, width = 50, height = 50},
		boxer.box {x = 200, y = 200, width = 50, height = 50},
	},
	padding = 32, -- optional property, adds padding to the box
}
```

If you already have a box with children and you want to adjust its bounds to neatly contain the children, you can call `box:wrap()`:

```lua
box:wrap(32) -- takes 1 argument for padding
```

### Images

Boxer has a special object for images.

```lua
local image = boxer.Image {
	x = 25,
	y = 25,
	image = love.graphics.newImage 'bean man.jpg',
	scaleX = 2,
	style = {
		idle = {color = {1, 1, 1, .5}},
		hovered = {color = {1, 1, 1, 1}},
	},
}
```

Images work mostly the same as boxes, but the `width` and `height` properties are optional in `boxer.image`, as those are inferred from the image's dimensions. Images also have `scaleX` and `scaleY` properties, which set the image's width and height to a factor of the image's original size. You can also set `width` and `height`, which will change the dimensions of the image to an absolute value regardless of the image's dimensions.

### Text

Boxer has two different objects for drawing text: `Text` and `Paragraph`.

The `Text` object draws text on a single line (or multiple lines if the text string contains newlines).

```lua
local text = boxer.Text {
	x = 30,
	y = 50,
	font = love.graphics.newFont(32),
	text = 'hello world!',
	scaleX = .5,
	scaleY = .5,
	style = {
		idle = {color = {1, 1, 1, .5}},
		hovered = {color = {1, 1, 1, 1}},
	},
}
```

Similarly to images, `Text` objects have `scaleX` and `scaleY` properties as well as `width` and `height` properties.

Boxer also provides a `Paragraph` object. The text in `Paragraph` objects will automatically wrap to new lines according to the maximum `width`.

```lua
local text = boxer.Paragraph {
	x = 30,
	y = 50,
	font = love.graphics.newFont(32),
	text = 'imagine that this is a very long piece of text',
	width = 400,
	align = 'center', -- optional, can be 'left', 'center', 'right', or 'justify'
}
```

Unlike `Text` objects, `Paragraph` objects don't have `scaleX` and `scaleY` properties. The `width` property is required in `boxer.paragraph`, and `height` is readonly, as that is inferred from the number of lines the text spans (as well as the font).

API
---

### Box

#### Constructors

```lua
local box = boxer.Box {...}
```
Creates a new box. Takes an options table to set the properties for the box. Any Box property can be defined in this table.

```lua
local box = boxer.wrap {children: table, padding: number = 0}
```
Creates a box that contains the specified children and adjusts the children's position to be relative to the new box. Optionally surrounds the children with the specified amount of padding.

#### Functions

```lua
local x = box:getX(offset: number = 0)
```
Gets the x coordinate of an arbitrary point along the x-axis of the box. An offset of `0` gets the left side, `0.5` gets the center, and `1.0` gets the right side.

```lua
local y = box:getY(offset: number = 0)
```
Gets the y coordinate of an arbitrary point along the y-axis of the box. An offset of `0` gets the left side, `0.5` gets the center, and `1.0` gets the right side.

```lua
local x, y, width, height = box:getRect()
```
Gets the position and size of the box. Useful for plugging into `love.graphics` functions, such as `love.graphics.rectangle`.

```lua
local containsPoint = box:containsPoint(x: number, y: number)
```
Returns whether the specified point is within the box's bounds. Custom classes can redefine this depending on the shape of the box.

```lua
local box = box:getChild(name)
```
Returns the child with the specified `name`, or `false` if there is none.

```lua
box:setX(x: number, anchorX: number = 0)
```
Sets the x position of a certain point along the x-axis of the box. The anchor will be remembered so that future changes to the width of the box will not change the position of the specified point.

```lua
box:setY(y: number, anchorY: number = 0)
```
Sets the y position of a certain point along the y-axis of the box. The anchor will be remembered so that future changes to the height of the box will not change the position of the specified point.

```lua
box:mousemoved(x: number, y: number, dx: number, dy: number, istouch: boolean)
```
Informs the box about mouse move events. The arguments correspond to those of the `love.mousemoved` callback.

```lua
box:mousepressed(x: number, y: number, button: number, istouch: boolean, presses: number)
```
Informs the box about mouse press events. The arguments correspond to those of the `love.mousepressed` callback.

```lua
box:mousereleased(x: number, y: number, button: number, istouch: boolean, presses: number)
```
Informs the box about mouse release events. The arguments correspond to those of the `love.mousereleased` callback.

```lua
box:draw()
```
Draws the box (if a style is set) and its children.

##### Functions useful for creating custom classes

```lua
local CustomBox = Box.extend()
```
Creates a new class that inherits from the given class. Custom properties can be defined by setting `CustomBox.properties`:

```lua
CustomBox.properties = {
	property1 = {
		get = function(self) ... end,
		set = function(self, value) ... end,
	},
	property2 = {},
}
```

Each property can have a custom getter and setter. If they're not defined, the property will default to being a dynamic property, like `box.width`.

```lua
box:validatePositionOptions(options)
```
Given an `options` table, throws an error if there's more than one horizontal or vertical position property in the table.

```lua
box:setCommonOptions(options)
```
Sets the following box properties according to the values in the `options` table, or a default if it's not defined:
- `x` (`0`)
- `left` (`0`)
- `center`
- `right`
- `y` (`0`)
- `top` (`0`)
- `middle`
- `bottom`
- `style`
- `children` (`{}`)
- `clipChildren`
- `transparent`
- `hidden`
- `disabled`
- `onMove`
- `onDrag`
- `onEnter`
- `onLeave`
- `onClick`
- `onPress`

Note that `width` and `height` are not set in this function, as different classes may use these properties in different ways. If you're extending from the base `Box` class, you will need to set these to *something*, even if they're dummy values of (0, 0).

```lua
box:getCurrentStyle(propertyName)
```
Gets the current value of the style property with the given `propertyName`, depending on whether the box is idle, hovered, or pressed.

```lua
box:drawSelf()
```
Draws the box itself without drawing its children. If you create a custom class, you can redefine this function to change how the box looks. Note that this function should always draw the box as if its position is (0, 0), as `box.draw` will apply the transformation for you.

```lua
box:stencil()
```
Draws the shapes that will be used to clip children if `clipChildren` is set to `true`. If you create a custom class, you can redefine this function to change how children are clipped. Note that this function should always draw the shapes as if the box's position is (0, 0), as `box.draw` will apply the transformation for you.

#### Callbacks

```lua
function box.onPress(button: number) ... end
```
Called when the box is clicked and released. Useful for creating buttons.

```lua
function box.onClick(button: number) ... end
```
Called as soon as the box is clicked.

```lua
function box.onEnter() ... end
```
Called when the mouse comes within bounds of the box.

```lua
function box.onLeave() ... end
```
Called when the mouse leaves the bounds of the box.

```lua
function box.onMove(relativeX: number, relativeY: number, displacementX: number, displacementY: number)
```
Called when the mouse is moved over the box. The arguments are the position of the mouse relative to the top-left corner of the box, and the amount the mouse was moved, respectively.

```lua
function box.onDrag(button: number, displacementX: number, displacementY: number)
```
Called when the box is clicked and dragged.

#### Properties
- `name` (`string`) - the name of the box.
- `style` (`table`) - the styles the box should use.
- `children` (`table`) - a list of the objects contained within this box. Children at a higher index in the table are considered to be "above" those with a lower index. If a child has a `name` property, you can also access it via `children[name]`.
- `clipChildren` (`boolean` | `function -> boolean`) - whether portions of the children outside of the box's bounds should be hidden and unclickable.
- `transparent` (`boolean` | `function -> boolean`) - whether the box should allow mouse events to pass through to lower children in the same parent box.
- `hidden` (`boolean`) - whether the box should be invisible.
- `disabled` (`boolean`) - whether the box should ignore mouse events.
- `hovered` (`boolean`) (readonly) - whether the mouse is currently over the box.
- `pressed` (`false | number`) (readonly) - the number of the mouse button the box is currently being held down by, or `false` if it is not being held down.

#### Style properties
- `outlineColor` (`table` | `function -> r, g, b, a`, `function -> table`) - the color to draw the outline with.
- `lineWidth` (`number` | `function -> number`) - the line width to use for drawing the outline.
- `fillColor` (`table` | `function -> r, g, b, a`, `function -> table`) - the color to draw the fill with.
- `radiusX` (`number` | `function -> number`) - the horizontal radius of the borders of the box.
- `radiusY` (`number` | `function -> number`) - the vertical radius of the borders of the box.

### Text
(inherits from Box)

#### Constructors

```lua
local text = boxer.Text {
	text: string,
	font: Font,
	...
}
```
Creates a new text object. Text and font properties are required, but any other box or text properties can be included in the options table.

#### Properties
- `text` (`string` | `function -> string`) - the text content to draw.
- `font` (`Font` | `function -> Font`) - the font to use for drawing. Fonts can be created using `love.graphics.newFont`.
- `scaleX` (`number` | `function -> number`) - the horizontal scaling factor of the text. Changing this will affect the `width` of the text.
- `scaleY` (`number` | `function -> number`) - the vertical scaling factor of the text. Changing this will affect the `height` of the text.
- `width` (`number`) - the total width of the text. Changing this will affect the `scaleX` of the text.
- `height` (`number`) - the total height of the text. Changing this will affect the `scaleY` of the text.

#### Style properties
- `color` (`table` | `function -> r, g, b, a`, `function -> table`) - the color of the text.
- `shadowColor` (`table` | `function -> r, g, b, a`, `function -> table`) - the color of the text's shadow. If undefined, the text will have no shadow.
- `shadowOffsetX` (`number` | `function -> number`) - the horizontal offset of the text's shadow in pixels. Defauls to 1 pixel.
- `shadowOffsetY` (`number` | `function -> number`) - the vertical offset of the text's shadow in pixels. Defauls to 1 pixel.

### Paragraph
(inherits from Box)

#### Constructors

```lua
local paragraph = boxer.Paragraph {
	width: number,
	text: string,
	font: Font,
	...
}
```
Creates a new paragraph object. Works similarly to the Text object, but the text is automatically split into lines depending on the `width` of the object.

#### Properties
- `text` (`string` | `function -> string`) - the text content to draw.
- `font` (`Font` | `function -> Font`) - the font to use for drawing. Fonts can be created using `love.graphics.newFont`.
- `align` (`string` | `function -> string`) - the alignment mode of the text. Can be `'left'`, `'center'`, `'right'`, or `'justify'`.
- `width` (`number`) - the width that a line of text is allowed to span.
- `height` (`number`) (readonly) - the total height of the paragraph. Unlike the Text object, this cannot be changed, as it is a product of the width of the box and the amount/size of text.

#### Style properties
- `color` (`table` | `function -> r, g, b, a`, `function -> table`) - the color of the text.
- `shadowColor` (`table` | `function -> r, g, b, a`, `function -> table`) - the color of the text's shadow. If undefined, the text will have no shadow.
- `shadowOffsetX` (`number` | `function -> number`) - the horizontal offset of the text's shadow in pixels. Defauls to 1 pixel.
- `shadowOffsetY` (`number` | `function -> number`) - the vertical offset of the text's shadow in pixels. Defauls to 1 pixel.

### Image
(inherits from Box)

#### Constructors

```lua
local image = boxer.Image {
	image: Image,
	...
}
```
Creates a new image object.

#### Properties
- `image` (`Image` | `function -> Image`) - the image to draw.
- `scaleX` (`number` | `function -> number`) - the horizontal scaling factor of the image. Changing this will affect the `width` of the image.
- `scaleY` (`number` | `function -> number`) - the vertical scaling factor of the image. Changing this will affect the `height` of the image.
- `width` (`number`) - the total width of the image. Changing this will affect the `scaleX` of the image.
- `height` (`number`) - the total height of the image. Changing this will affect the `scaleY` of the image.

#### Style properties
- `color` (`table` | `function -> r, g, b, a`, `function -> table`) - the color of the image (blends with the colors of the image content).

Contributing
------------
Boxer is in early development, so feel free to open issues and make pull requests! Give me all of your good design thoughts, and if you use this library, let me know how it works for you!

License
-------
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
