## Runtime Systems

### Overview

This repo contains work for Sonia & Gwyneth's course project for CS263 Runtime Systems with Prof. Chandra Krintz at the University of California Santa Barbara. The aim of this project is to investigate embedded scripting languages that are used to develop authoring tools.

#### Week 0

GOALS

- *Lua set-up.* Install Lua and run hello world
- *Runtimes and profilers.* Look into different runtimes and profilers.
- *Logistics.* Getting off the ground (vision statement, git repo).
- *Lua specifics.* How is Lua meant to be used? What is the Lua way?

OUTCOMES

-  *Lua set-up.* Went great!
	- A simple hello world in Lua
	[[helloworld.lua](week0/helloworld.lua)]
	- Our version of learnLuainXmin: [[learnluainXmin.lua](week0/learnluainXmin.lua)]
- *Logistics.* We're still developing our workflow and troubleshooting but we like using Atom's teletype for collaborating at the same time.
	- We use a log to track daily work [[log.md](log.md)]
	- Our vision statement is here [[vision-statement.md](week0/vision-statement.md)]
-  *Runtimes and profilers.* We barely got started on this... maybe dipped our toes. Tabled to week 1.
- *Lua specifics.* Wrote short scripts and learned some features of Lua... will continue to build on this.
	- We're still getting comfortable with writing code in Lua and don't feel like we've arrived at the fluency where we can do things the "Lua way".
	- We wrote two simple command line games:
		- Tic Tac Toe [[tictactoe.lua](week0/tictactoe.lua)]
		- A UCSB-themed command line memory game: [[memory_puzzle.lua](week0/memory_puzzle.lua)]
	- We started writing out an overview that goes over lua specific features [[lua-specific-features.md](week1/lua-specific-features.md)]


### Week 1

GOALS

- *Runtimes and profilers.* Look into different runtimes and profilers.
- *Lua specifics.* Write a guide and read up on Lua specific features. Write some short programs that utilize these.


OUTCOMES

- *Profilers.*
	- We looked at three different profilers. In all three cases the code was no longer maintained and needed fixing.
		- [Pepperfish.](week1/pepperfish_profiler.lua)
		- [Profiler in Lua.](week1/profiler_in_lua.lua)
		- [Lua Callgrind](week1/lua-callgrind.lua) (overview available on the [website](https://jan.kneschke.de/projects/misc/profiling-lua-with-kcachegrind)).
	- The first two profilers are time-based and minimalistic, while the third requires qcachegrind and is able to generate some really awesome visualizations.
- *Runtimes*.
	- [LuaJIT](https://luajit.org/install.html) is a just-in-time compiler for Lua. It is available both on its own and as part of the [Luapower distribution](https://luapower.com). Part of what makes LuaJIT interesting is that it claims to be "one of the fastest dynamic language implementations".
	- There are several other Lua runtimes and distributions, but it appears that most are no longer maintained. See, for example: [Lua AIO](http://luaaio.luaforge.net/index.html), [murgaLua](http://www.murga-projects.com/murgaLua) and [wxLua](http://wxlua.sourceforge.net).


### Week 3

GOALS

- *Understand the Lua interpreter.* Eventual aim is to add a superinstruction.
- *Understand the bytecode for simple Lua programs.*
	- [Chunkspy](http://luaforge.net/projects/chunkspy) is an _awesome_ tool for this. Note that it requires Lua 5.1 (latest stable version is 5.3, with 5.4 to be released in the near future). Interactive usage: `lua-5.1 ChunkSpy.lua --interact --auto`.
	- One can also use the bytecode compiler, e.g. `luac -o output.luac input.lua`. A fun idea is to write a bytecode parser that extracts human-readable information from a bytecode file, similar to ChunkSpy. _I really want to do this now._


### Week 4

- *Decompiler*
	- Gwyneth working on bytecode parser
- *Project Direction*
	- Meeting with Chandra to discuss project direction
	- Some options... (1) Looking at evolution of Lua, (2) focusing on Terra, (3) suggesting and trying to implement a superinstruction in Lua
	- Aim: Deep Dive into Lua
		- Resources on Lua (learning, profilers, decompilers)
		- Survey discussion (includes Lua survey, LuaJIT and Terra paper)
		- Decompiler & Superinstruction
- Reading -- see [survey.md](deliverables/survey.md)
- *Superinstruction*
	- Lua bytecode challenging to find, plenty of source
	- Aim is to compile it and analyze the bytecode
	- LuaJIT upwards compatible with Lua 5.1
	- LuaRocks module exploration page shows dependencies --> can filter out which version of Lua to use 
