Boxer
-----

**Boxer** is a library for arranging and drawing shapes in LÖVE. It's best used for positioning rectangular objects, such as images and text. It also handles mouse events, making it a good base for UI work.

Installation
============
To use Boxer, place boxer.lua in your project, and then `require` it in each file where you need to use it:

```lua
local boxer = require 'boxer' -- if your boxer.lua is in the root directory
local boxer = require 'path.to.boxer' -- if it's in subfolders
```

Usage
=====

### Creating boxes

Boxes are the basic object created by Boxer. They're useful for drawing rectangles, positioning items, handling mouse events, and grouping items to gether.

To create a box, use `boxer.new`:

```lua
local box = boxer.new(options)
```

`options` is a table of properties that will be used to initialize the box. There are a few required properties:
- `x`/`left`/`center`/`right` (`number` | `function() -> number`) - sets the horizontal position of the box. You must define exactly one of these properties.
- `y`/`top`/`middle`/`bottom` (`number` | `function() -> number`) - sets the vertical position of the box. You must define exactly one of these properties.
- `width` (`number` | `function() -> number`) - the width of the box.
- `height` (`number` | `function() -> number`) - the height of the box.

Each of these properties can be either a number or a function that returns a number.

There are also a number of optional properties:
- `children` (`table`) - a list of child Boxer objects that the box should contain
- `clipChildren` (`boolean` | `function() -> boolean`) - whether portions of children outside of the box should be hidden and unclickable
- `transparent` (`boolean` | `function() -> boolean`) - whether the box should allow mouse events to pass through to boxes on a lower layer (only applies if the box is a child of another box)
- `name` (`string`) - the name of the box. Can be used to access children via name if the box is a child of another box.
- `hidden` (`boolean`) - whether the box (and its children) should be invisible.
- `disabled` (`boolean`) - whether the box (and its children) should ignore mouse events.
- `onPress` (`function(button)`) - a function to call whenever the box is pressed. The number of the mouse button is passed as the first argument.
- `onClick` (`function(button)`) - a function to call as soon as the box is clicked. The number of the mouse button is passed as the first argument. This is different from `onPress`, which waits for the mouse to be released before it fires. If you want standard button clicking behavior, you probably want `onPress`.
- `onEnter` (`function()`) - a function to call when the mouse enters the bounds of the box.
- `onLeave` (`function()`) - a function to call when the mouse leaves the bounds of the box.
- `onMove` (`function(relX, relY, dx, dy)`) - a function to call when the mouse is moved over the box. The functions is called with four arguments: the x position of the mouse relative to the top-left corner of the box, the y position of the mouse relative to the top-left corner of the box, the horizontal distance the mouse moved, and the vertical distance the mouse moved.
- `onDrag` (`function(button, dx, dy)`) - a function to call when the box is dragged. The function is called with three arguments: the number of the mouse button used, the horizontal distance the mouse moved, and the vertical distance the mouse moved.

All of these properties can also be set on the box directly after it is created.

### Positioning boxes

Once you've created a box, there's a number of ways you can read and change its size and position. The easiest way is using the box's properties:
- `x`/`left` - the x position of the left side of the box
- `center` - the x position of the horizontal center of the box
- `right` - the x position of the right side of the box
- `y`/`top` - the y position of the top of the box
- `middle` - the y position of the vertical center of the box
- `bottom` - the y position of the bottom of the box
- `width` - the width of the box
- `height` - the height of the box

For example, you could shift one box horizontally so its left edge is lined up with another box's right edge like this:

```lua
box2.left = box1.right
```

You can set any of these properties to either a number or a function that returns a number. If set to a function, the property will be automatically updated to whatever value the function returns. For example, this code will keep the right side of a box aligned to the right side of the screen, even if the window is resized:

```lua
box.right = function()
	return love.graphics.getWidth()
end
```

When setting a position, the part of the box that was set is remembered. So after running the above code, if you changed the `width` of the box, it would grow to the left, leaving the right side in its correct position.

If you need more control over the position of a box, you can use `getX`/`getY` to get an arbitrary position or `setX`/`setY` to set an arbitrary position. The `get` functions take one argument - the offset. An offset of `0` will get the left/top of the box, an offset of `1` will get the right/bottom of the box, and `1/3` will get the point one third of the way from one side to the other. Similarly, the `set` functions take two arguments - one for the position, and one for the anchor.

For example, this code would set the bottom of one box to be 40% of the way down the vertical axis of another box:

```lua
box2:setY(box1:getY(.4), 1)
```

### Mouse events

### Drawing boxes

### Children

### Images

### Text

Contributing
============
Boxer is in early development, so feel free to open issues and make pull requests! Give me all of your good design thoughts, and if you use this library, let me know how it works for you!

License
=======
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
