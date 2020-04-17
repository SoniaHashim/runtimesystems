--------------------------------------------------------------------------
--[[
learnluainXmin.lua
version: 200416
-----------------------------
Learn Lua in 15 min tutorial by Tyler Neylon
Accessed from: http://tylerneylon.com/a/learn-lua/

Modified but follows overall structure. Thanks Tyler!
Also apparently this was the first one written by him the other
learnXinYmin tutorials (which are all great, thanks) followed

--]]
--------------------------------------------------------------------------

-- (1) Variables

x = 42 -- All numbers are doubles

s1 = 'hello' -- Strings immutable
s2 = "hello"

sm = [[ multiline strings use
 		similar syntax
		as block comments ]]

n = nil -- Nil undefines var

-- (2) Conditionals

n = 0
while n < 2 do
	n = n + 1 -- note: No unary operators (++, +=)
end

if n >= 5 then
	print 'over 5' -- note: Print with one literal param doesn't need parens
elseif s1 ~= 'hello' then -- note: Not equals is ~=
	io.write('still under 5') -- note: Defaults to stdout.
else
	thisIsGlobal = 5 -- note: Vars global by default, camel case
	local thisIsLocal = 4
	print 'Type in a name below'
	local line = io.read()
	print('Hi there, ' .. line) -- note: String concatenation via .. operator
end

foo = unknown -- note: Not an error to use undefined vars (foo set to nil)
isAStrawberry = false -- note: nil and false return false; 0 and '' are true!
if not isAStrawberry then print 'It wasn\'t a berry' end

-- note: 'or' and 'and' short circuit (This is similar to ternary a?b:c)
ret = isAStrawberry and 'yes' or 'no' -- ret is no

sum = 0
for i = 1,100 do -- note: Range is inclusive, range = begin, end[, step]
	sum = sum + 1
end

repeat print 'don\'t panic'
	n = n - 1
until n == 0

-- (3) Functions

function fib(n)
	if n < 2 then return 1 end
	return fib(n-2) + fib(n-1)
end

-- note: Closures and anonymous functions are ok:
function adder(x)
	-- e.g. returned function created when adder is called and remembers x value
	return function (y) return x + y end
end
a1 = adder(7)
a2 = adder(12)
print(a1(3)) --> 10
print(a2(8)) --> 20

-- note: Returns, func calls, assignments work with lists that don't have
-- to be aligned in length. Unmatched receivers set to nil, unmatched senders
-- discarded
x, y, z = 1, 2, 3, 4 -- e.g. 4 is thrown away

function bar(a,b,c)
	print(a,b,c)
	return 4,8,15,16,23,42
end

x,y = bar('arthur') -- e.g. prints "arthur nil nil" and x = 4, y = 8

-- note: Functions are first-class and can be local or global
-- e.g. these are the same (global)
function f(x) return x*x end
f = function (x) return x*x end
-- e.g. these are the same (local)
local function g(x) return math.sin(x) end
local g; g = function(x) return math.sin(x) end

-- note: Trig funcs in radians

-- (4) Tables
-- note: Tables are associative arrays and constitute Lua's only compound data
-- structure. They are hash-lookup dicts that can be used as lists

-- Using tables as dictionaries / maps
-- note: By default, dict literals use string keys
t = {k1 = 'val1', k2 = false}
print(t.k1) -- e.g. prints 'val1', note: Dot notation
t.nK = {} 	-- e.g. adds new key/value pair
t.k2 = nil  -- e.g. removes k2

-- note: Literal notation for any non-nil value as key
u = {['@!#'] = 'zaphod', [{}] = 43, [42] = 'just-keep-swimming'}
print(u[42]) -- e.g. prints 'just-keep-swimming'

-- note: Key matching by value for numbers and strings
z = u['@!#'] -- e.g. a = 'zaphod'
print(z)
-- note: Key matching by identity for tables
b = u[{}] -- e.g. b = nil since lookup fails
print(b)

-- note: A one-table-param function call doesn't need parens
function h(x) print(x.k1) end
h{k1 = 'Dory'} -- e.g. prints Dory

-- Iterate through a table
for k,v in pairs(t) do
	print(k,v)
end

-- note: _G is a special table of all globals
-- print(_G)

-- Using tables as lists / arrays
l = {'v1', 'v2', 2.0, 'memory'} -- note: implicit int keys
for i = 1, #l do -- note: index by 1, #l is size of l
	print(l[i])
end -- note: l (a table with consecutive integer keys) can be used as a list

-- (5) Metatables and metamethods
-- note: A metatable gives a table operator-overlad-like behavior also similar
-- to prototypes

-- e.g. if f1 and f2 are fractions, how to add them?
f1 = {a = 1, b = 2}
f2 = {a = 2, b = 3}

metafraction = {}
function metafraction.__add(f1,f2)
	sum = {}
	sum.b = f1.b*f2.b
	sum.a = f1.a*f2.b + f2.a*f1.b
	return sum
end

-- Setting a metatable sets operations that can be called on metatables
setmetatable(f1, metafraction)
setmetatable(f2, metafraction)
-- e.g. call __add(f1,f2) on f1's metatable
s = f1+f2
-- note: Prototypes in js have keys but in Lua retrieve metatables as
-- getmetatable(f1)
-- note: Adding s + s would fail since s has no metatable, how to fix this?

-- An __index on a metatable overloads dot lookups
defaultFavs = {animal = 'babyyoda', food = 'berries'}
myFavs = {food = 'spinach'}
setmetatable(myFavs, {__index = defaultFavs})
eatenBy = myFavs.animal
print(eatenBy)
-- i.e. direct table lookups that fail retry with metatable's index val
-- and this recurses. Note: __index val can also be a function

-- Values of __index, add, etc. are metamethods. Here's the full list where
-- a is a table with the metamethod
-- __add(a, b)                     for a + b
-- __sub(a, b)                     for a - b
-- __mul(a, b)                     for a * b
-- __div(a, b)                     for a / b
-- __mod(a, b)                     for a % b
-- __pow(a, b)                     for a ^ b
-- __unm(a)                        for -a
-- __concat(a, b)                  for a .. b
-- __len(a)                        for #a
-- __eq(a, b)                      for a == b
-- __lt(a, b)                      for a < b
-- __le(a, b)                      for a <= b
-- __index(a, b)  <fn or a table>  for a.b
-- __newindex(a, b, c)             for a.b = c
-- __call(a, ...)                  for a(...)

-- (6) Class-like tables and inheritance
-- note: Classes aren't built-in but they can be constructed using tables
-- and metatables

Dog = {}								-- Dog is a table that acts like a class
function Dog:new()						-- function tablename:fn(...) == tablename.fn(self,....)
	newObj = {sound = 'boof'}			-- newObj is instance of class Dog
	self.__index = self 				-- self = class instantiated, newObj gets self functions
	return setmetatable(newObj, self)   -- returns first arg in this case newObj
end

function Dog:makeSound()				-- self is instance instead of class (using : operator)
	print('dog says '..self.sound)
end

Lily = Dog:new()						-- same as Dog.new(Dog), self = Dog in new()
Lily:makeSound() -- 'dog says boof'		-- same as Lily.makeSound(Lily); self = Lily

-- Inheritance

LoudDog = Dog:new()						-- Gets Dog's methods and variables
function LoudDoug:makeSound()
	s = self.sound .. ' '				-- self has 'sound' key from new
	print(s .. s .. s)
end

Lilliput = LoudDog:new()				-- LoudDog.new(LoudDog) --> Dog.new(LoudDog)
Lilliput.makeSound() -- 'boof boof boof'-- LoudDog.makeSound(Lily)
-- note: traversal through Lily.key, LoudDog.key, Dog.key

function LoudDog:new() 					-- Subclass's new is like the base
	newObj = {}
	-- set up newObj
	self.__index = self
	return setmetatable(newObj, self)
end

-- (7) Modules

--[[

-- Suppose this is the file mod.lua...

local M = {}

local function sayMyName() -- note: locals inside mod are invisible outside it
	print('WallE')
end

function M.sayHello()
	print('Whale hello there')
	sayMyName()
end

return M

-- ... then another file can use mod.lua

local mod = require('mod') -- note: This runs mod.lua
-- note: require is how modules are included and acts as follows
local mod = (function()
	< contents of mod.lua>
end)()

mod.sayHello() -- says hello to WallE
mod.sayMyName() -- error

-- note: require's return values are cached so a file is run at most once
-- (basically protection against multiple inclusions)

-- e.g. suppose mod2.lua contains print 'I am alive!'
local a = require('mod2') 		-- prints 'I am alive!'
local b = require('mod2') 		-- Doesn't print and a = b

-- dofile does the same thing without caching
dofile('mod2.lua') 				-- prints 'I am alive!'
dofile('mod2.lua') 				-- prints 'I am alive!' again

-- loadfile loads the file but doesn't run it
f = loadfile('mod2.lua')
f() 							-- prints 'I am alive!'

-- loadstring is loadfile for strings
g = loadstring('great we made it')
g() 							-- prints 'great we made it'

]]--
