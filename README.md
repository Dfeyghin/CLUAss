# CLUAss - a lua class module for Roblox #
This Class module is based off of "Classic" (the lua Class library found in luarocks.org)
It defines a base class from which all classes inherit and provides a similar behavior to Java/C# classes

### version 1.1 ###

The Class supports the following behaviors/actions:
	
* inheritance
* interface implementation
* class-type checking
* static variables/functions
* variables and metamethod implementation
* destruction of the class and all its members (Roblox behavior)
  
  
  
This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See LICENSE for details.


Changelog v1.1:

	* Added a global destructor method


## HOW TO  USE: ##

1.  require in any module script that intends to be implmeneting a class as follows : 
```lua
local Class = require(ReplicatedStorage.Libraries.Class).
```
2.  to create a new class in said module: instead of creating a standard table via the original table init, you now call Class() as follows:
```lua
--use this:
local classExample = Class() 
--instead of this:
local module = {}
```

3.  to define a constructor with any number of arguments, use:
```lua
class:New()
```

4.  to create a new Instance/Object of the class (outside of the moduleScript), after requiring, call via:
```lua
local instanceExample = classExample(params)
```
5.  to use inheritance, in the module of the inheriting class use:
```lua
local inherittingClass = parentClass:Extend()
```
* you can use the constructor of the parent class inside the constructor of the inheritting class to initialize some
	basic behavior and expand it; access parent class using:
```lua
inherittingClass.Parent
```

6.  to implement interfaces (enforce specific function set(s)), you can create an interface using the Class() call from
	step 1 and then use: 
```lua
classExample:Implement(interfaceExample)
```

7.  to use static variables/functions, simply add them to the Class table like so: 
```lua
local classExample = Class()
classExample.staticVariable = 5
```

8. you can add metamethods directly to the class as well like so:
```lua   
function classExample:__add(other)
    return self.x + other.x
end
```

## FULL EXAMPLE: ##

### Usage ###
```lua
Class = require(ReplicatedStorage.Libraries.Class)
```
### Creating a new class ###
```lua
Point = Class()

function Point:New(x, y)
    self.x = x or 0
    self.y = y or 0
end
```
### Create a new object of type Point ###

	local p = Point(10, 20)
  
### Extending an existing class ###
```lua
Rect = Point:Extend()

function Rect:New(x, y, width, height)
    --call parent with self, notice that to do so, you have to index Parent's New function with a '.' and not a ':'
    Rect.Parent.New(self, x, y)
    self.width = width or 0
    self.height = height or 0
end
```

### Checking an object's type ###
```lua
local p = Point(10, 20)
print(p:IsA(Class)) -- true
print(p:IsA(Point)) -- true
print(p:IsA(Rect)) -- false 
```
	
### Implementing interfaces ###
```lua
PairPrinter = Class()

function PairPrinter:printPairs()
    for k, v in pairs(self) do
        print(k, v)
    end
end

Point = Class()
Point:Implement(PairPrinter)

function Point:new(x, y)
    self.x = x or 0
    self.y = y or 0
end

local p = Point()
p:printPairs() -- x 0     y 0
```
	
### Using Static Variables ###
```lua
Point = Class()
Point.scale = 2

function Point:New(x, y)
    self.x = x or 0
    self.y = y or 0
end

function Point:GetScaled()
    return self.x * Point.scale, self.y * Point.scale
end
```

### Creating a metamethod ###
```lua
function Point:__tostring()
    return self.x .. ", " .. self.y
end
```
### Destroying an instance of the Class ###
```lua
instance:Destroy()
```
	
