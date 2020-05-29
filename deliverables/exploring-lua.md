# Exploration: Resources for Lua

## Learning

### Start Here

1. [LearnLuainYMin](https://learnxinyminutes.com/docs/lua/): This 15 min tutorial is a quick overview of Lua basics.

2. [LuaTut](http://luatut.com/): The Lua tutorial is provides a similar quick intro to Lua in the crash course but is less comparative to other common programming languages.

### Official Resources

1. [Lua Reference Manual](https://www.lua.org/manual/5.3/): Given that Lua is such a lightweight langauge, the reference manual is under a 100 pages and covers design choices and is a good way to begin understanding the internals of the language.

2. [Lua Course Notes](https://dcc.ufrj.br/~fabiom/lua/): Programming in Lua by Prof. Fabio Mascarenhas is a course based of the official Lua text (see below) and course notes are publicly accessible.

*Programming in Lua*: The official guide to Lua. Note: the version for Lua 5.0 is available online.
[Amazon, for Lua 5.3](https://www.amazon.com/exec/obidos/ASIN/8590379868/theprogrammil4-20)

## Runtimes

1. [Lua 5.1 Runtime](../weeks4&5/runtime_lua5_1.md)

2. [LuaJIT Runtime](../weeks4&5/runtime_luajit.md)

## Profilers

1.  [Pepperfish Profiler](../week1/pepperfish_profiler.lua): a simple time-based profiler for Lua 5.1. The source code is also available [here](http://lua-users.org/wiki/PepperfishProfiler).

2.  [Profiler in Lua](../week1/profiler_in_lua.lua): another time-based profiler.

3. [Lua Callgrind](../week1/lua-callgrind.lua): requires qcachegrind and is able to generate some really awesome visualizations (overview available [here](https://jan.kneschke.de/projects/misc/profiling-lua-with-kcachegrind)).

## Decompilers

1. A list of bytecode decompilers is provided [here](http://lua-users.org/wiki/LuaTools). Most are for previous versions of Lua.
