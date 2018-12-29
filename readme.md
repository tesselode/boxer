Boxer
=====

**Boxer** is a library for arranging and drawing shapes in LÖVE. It's best used for positioning rectangular objects, such as images and text. It also handles mouse events, making it a good base for UI work.

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

A box is the basic object that Boxer creates. To create a box, use `boxer.box`:

```lua
local box = boxer.box {
	x = 500,
	bottom = 300,
	width = 50,
	height = 75,
}
```

To create a box, you have to define exactly one horizontal position property (`x`, `left`, `center`, or `right`) and one vertical position property (`y`, `top`, `middle`, or `bottom`), as well as `width` and `height` properties. These are the only required properties, but you can also pass in any other valid `Box` properties (see the [Box API](#box) for more details).

### Positioning boxes

The easiest way to position boxes is to set the position properties. For example, this code will shift a box horizontally so its right edge is lined up with another box's left edge:

```lua
box2.right = box1.left
```

You can also set many box properties to a function, and the property will be automatically updated to the function's return value. For example, this code will keep a box's bottom edge aligned with the bottom of the window, even if the window is resized:

```lua
box.bottom = function()
	return love.graphics.getHeight()
end
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

### Children

### Images

### Text

API
---

### Box

#### Constructors

```lua
local box = boxer.box {
	x/left/center/right: number,
	y/top/middle/bottom: number,
	width: number,
	height: number,
	...
}
```
Creates a new box. Takes an options table to set the properties for the box. Exactly one horizontal position property and one vertical position property must be defined, as well as `width` and `height`. Any other box properties can also be defined to set them immediately on the new box.

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
Returns whether the specified point is within the box's bounds.

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
function box.onMove(button: number, displacementX: number, displacementY: number)
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
- `outlineColor` (`table` | `function -> table`) - the color to draw the outline with.
- `lineWidth` (`number` | `function -> number`) - the line width to use for drawing the outline.
- `fillColor` (`table` | `function -> table`) - the color to draw the fill with.
- `radiusX` (`number` | `function -> number`) - the horizontal radius of the borders of the box.
- `radiusY` (`number` | `function -> number`) - the vertical radius of the borders of the box.

### Text
(inherits from Box)

#### Constructors

```lua
local text = boxer.text {
	x/left/center/right: number,
	y/top/middle/bottom: number,
	text: string,
	font: Font,
	...
}
```
Creates a new text object. Position, text, and font properties are required, but any box or text properties can be included in the options table. Unlike the `Box` constructor, `width` and `height` are optional.

#### Properties
- `text` (`string` | `function -> string`) - the text content to draw.
- `font` (`Font` | `function -> Font`) - the font to use for drawing. Fonts can be created using `love.graphics.newFont`.
- `scaleX` (`number` | `function -> number`) - the horizontal scaling factor of the text. Changing this will affect the `width` of the text.
- `scaleY` (`number` | `function -> number`) - the vertical scaling factor of the text. Changing this will affect the `height` of the text.
- `width` (`number`) - the total width of the text. Changing this will affect the `scaleX` of the text.
- `height` (`number`) - the total height of the text. Changing this will affect the `scaleY` of the text.

#### Style properties
- `color` (`table` | `function -> table`) - the color of the text.

### Paragraph
(inherits from Box)

#### Constructors

```lua
local paragraph = boxer.paragraph {
	x/left/center/right: number,
	y/top/middle/bottom: number,
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
- `color` (`table` | `function -> table`) - the color of the text.

### Image
(inherits from Box)

#### Constructors

```lua
local image = boxer.image {
	x/left/center/right: number,
	y/top/middle/bottom: number,
	image: Image,
	...
}
```
Creates a new image object. Position and image properties are required, but any box or image properties can be included in the options table. Unlike the `Box` constructor, `width` and `height` are optional.

#### Properties
- `image` (`Image` | `function -> Image`) - the image to draw.
- `scaleX` (`number` | `function -> number`) - the horizontal scaling factor of the image. Changing this will affect the `width` of the image.
- `scaleY` (`number` | `function -> number`) - the vertical scaling factor of the image. Changing this will affect the `height` of the image.
- `width` (`number`) - the total width of the image. Changing this will affect the `scaleX` of the image.
- `height` (`number`) - the total height of the image. Changing this will affect the `scaleY` of the image.

#### Style properties
- `color` (`table` | `function -> table`) - the color of the image (blends with the colors of the image content).

Contributing
------------
Boxer is in early development, so feel free to open issues and make pull requests! Give me all of your good design thoughts, and if you use this library, let me know how it works for you!

License
-------
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
