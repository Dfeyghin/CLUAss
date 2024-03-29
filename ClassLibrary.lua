--[[--------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
​
This Class module is based off of "Classic" (the lua Class library found in luarocks.org)
It defines a base class from which all classes inherit and provides a similar behavior to Java/C# classes
​
The Class supports the following behaviors/actions:
 --inheritance
 --interface implementation
 --class-type checking
 --static variables/functions
 --variables and metamethod implementation
​
This module is free software; you can redistribute it and/or modify it under
the terms of the MIT license. See LICENSE for details.
​
​
--version 1.2--
---------------

Changelog v1.2:
	--Added a bindableEvent generator method for clean and clear internal events creation
	--Added a bindableFunction generator method for clean and clear internal function creation


Changelog v1.1:
	--Added a global destructor method

​
]]----------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------- HOW TO  USE: -------------------------------------------------
--[[--------------------------------------------------------------------------------------------------------------------
​
1.  require in any module script that intends to be implmeneting a class as follows : 
	local Class = require(ReplicatedFirst:WaitForChild("Libraries").Class).
​
2.  to create a new class in said module: instead of creating a standard table via 'local module = {}' ,
	use 'local classExample = Class()'.
​
3.  to define a constructor use: 'class:New()' with any number of arguments.
​
4.  to create a new Instance/Object of the class (outside of the moduleScript), after requiring, call via:
	'local instanceExample = classExample(params)'.
​
5.  to use inheritance, in the module of the inheriting class use: 'local inherittingClass = parentClass:Extend()'.
    you can use the constructor of the parent class inside the constructor of the inheritting class to initialize some
    basic behavior and expand it; access parent class using 'inherittingClass.Parent'.
   
6.  to implement interfaces (enforce specific function set(s)), you can create an interface using the Class() call from
	step 1 and then use: 'classExample:Implement(interfaceExample)'
​
7.  to use static variables/functions, simply add them to the Class table like so: 'local classExample = Class()' and 
	then 'classExample.staticVariable = 5'
​
8. you can add metamethods directly to the class as well like so:
      function classExample:__add(other)
            return self.x + other.x
      end
​
​
FULL EXAMPLE:
​
--Usage:
--------
​
	Class = require(ReplicatedFirst:WaitForChild("Libraries").Class)
​
​
--Creating a new class:
-----------------------
​
	Point = Class()
​
	function Point:New(x, y)
	  self.x = x or 0
	  self.y = y or 0
	end
​
​
--Create a new object of type Point:
------------------------------------
​
	local p = Point(10, 20)
​
​
--Extending an existing class:
------------------------------
​
	Rect = Point:Extend()
​
	function Rect:New(x, y, width, height)
	  --call parent with self, notice that to do so, you have to index Parent's New function with a '.' and not a ':'
	  Rect.Parent.New(self, x, y)
	  self.width = width or 0
	  self.height = height or 0
	end
​
​
--Checking an object's type:
----------------------------
​
	local p = Point(10, 20)
	print(p:IsA(Class)) -- true
	print(p:IsA(Point)) -- true
	print(p:IsA(Rect)) -- false 
	
	
--Implementing interfaces:
--------------------------
​
	PairPrinter = Class()
​
	function PairPrinter:printPairs()
	  for k, v in pairs(self) do
	    print(k, v)
	  end
	end
​
	Point = Class()
	Point:Implement(true, PairPrinter)
​
	function Point:new(x, y)
	  self.x = x or 0
	  self.y = y or 0
	end
​
	local p = Point()
	p:printPairs() -- x 0     y 0
	
	
--Using Static Variables:
-------------------------
​
	Point = Class()
	Point.scale = 2
​
	function Point:New(x, y)
	  self.x = x or 0
	  self.y = y or 0
	end
​
	function Point:GetScaled()
	  return self.x * Point.scale, self.y * Point.scale
	end
​
​
--Creating a metamethod:
------------------------
​
	function Point:__tostring()
		return self.x .. ", " .. self.y
	end
	
	
​
]]----------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------
local DESTRUCTION_DELAY = 1


local Class = {}
Class.__index = Class

-- "abstract" constructor, to be overridden by the class when defined
function Class:New()
end


-- Extend method to create inheritance
function Class:Extend()
	local class = {}
	--inherit the call wrapper and all metamethods:
	for k,v in pairs(self) do
		if k:sub(1,2) == "__" then
			class[k] = self[k]
		end
	end
	class.__index = class
	class.Parent = self
	
	setmetatable(class, self)
	return class
end

-- Implement method to support interface compliance
function Class:Implement(overide : boolean , ... : any)
	for _, class in pairs({...}) do
		for k, v in pairs(class) do
			if (overide or self[k] == nil) and type(v) == "function" then
				self[k] = v
			end
		end
	end
end


-- Check which type is the class
function Class:IsA(T)
	local mt = getmetatable(self)
	while mt do
		if mt == T then
			return true
		end
		mt = getmetatable(mt)
	end
	return false
end

--generate a new event for the class and return it's ID for internal use and event instance for external use
function Class:NewEvent(eventName)
	if not self._events then self._events = {} end
	local event = Instance.new("BindableEvent")
	event.Name = eventName
	table.insert(self._events, event)
	return #self._events , event.Event
end

--generate a new event for the class and return it's ID for internal use and event instance for external use
function Class:NewFunction(functionName)
	if not self._functions then self._functions = {} end
	local func = Instance.new("BindableFunction")
	func.Name = functionName
	table.insert(self._functions, func)
	return #self._functions , func.OnInvoke
end


function Class:GetFunction(id)
	if not id or not self._functions or not self._functions[id] then return end
	return self._functions[id]
end

function Class:GetEvent(id)
	if not id or not self._events or not self._events[id] then return end
	return self._events[id]
end

--metamethod for when 'print(Class)' is called
function Class:__tostring()
	return "ClassObject"
end

--metamethod for when attempted to concat the table
function Class.__concat(first, second)
	return tostring(first)..tostring(second)
end

-- will execute upon a call of any class that extends this main Class.
function Class:__call(...)
	local obj = setmetatable({}, self)
	obj._onDestroyEventId, obj.OnDestroy = obj:NewEvent("OnDestroy")
	obj:New(...)
	return obj
end


-- destroy helper function to handle each type of child of target
local function Destroy(target)
	for k,v in pairs(target) do
		if typeof(target[k]) == "table" then
			if target[k]["Destroy"] then target[k]:Destroy() else Destroy(target[k]) end --call recursively destroy function on the table
		elseif typeof(target[k]) == "RBXScriptConnection" then 
			target[k]:Disconnect()
		elseif typeof(target[k]) == "Instance" then
			target[k]:Destroy()
		elseif typeof(target[k]) == "thread" then --kill running tasks
			task.cancel(target[k])
		end
		target[k] = nil
	end
	target = nil
end


-- Global destructor to destroy object and leave no memory traces
function Class:Destroy()
	if self:GetEvent(self._onDestroyEventId) then self:GetEvent(self._onDestroyEventId):Fire() end
	task.delay(DESTRUCTION_DELAY, function() Destroy(self) end)
end


-- will execute Class:Extend() when the required Class will be executed
return setmetatable(Class, {__call = function() return Class:Extend() end})
