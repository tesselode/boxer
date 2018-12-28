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
