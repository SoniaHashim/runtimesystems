## Daily Log

#### Week 0 -- Intro to Lua

[200414]

- *Lua set-up.* Install Lua and run hello world
- *Runtimes and profilers.* Look into different runtimes and profilers.
- *Logistics.* Getting off the ground (vision statement, git repo).
- *Lua specifics.* How is Lua meant to be used? What is the Lua way?

- Established workflow and wrote out vision statement. We each installed Lua and wrote our first hello world programs! To run, execute lua helloworld.lua on the command line.

[200415]

- Installing Lua, 2.0. I went through the readme for Lua 5.3 [available here](http://lua-users.org/wiki/LuaDistributions) and found this that showcases Lua's structure. There's also a `luaconf.h` file that allows for customization of Lua's features which is something we can revisit later.

	![lua-structure](lua-structure.png)

- We read Lua's [wikipedia page](https://en.wikipedia.org/wiki/Lua_(programming_language)).
	- We learned a lot about the language's history. Here are some highlights:
		- Lua was developed in the early 90s just a year or two after Python
		- Lua is the Portuguese word for "moon" since its predecessor was named Sol "sun"
		- Some languages that influenced specific features included Modula, CLU, C++, SNOBOL, LISP and Scheme and (one of my favorites) AWK.
	- I also have a lot of questions:
		- Why did Lua evolve as a "multi-paradigm" language and what does that mean for developers? (In both writing applications and compilers)
		- What are "meta-features"? That sounds so cool
		- Why are there two ways to do print statements? It's a little odd that I can do hello world two different ways
		- Why do local vars have to be specified with a keyword `local`?
		- Why is the VM register based instead of stacked based?
	- Other observations:
		- For a lightweight language with a small base, Lua still seems to have a lot of advanced features!
		- Lua uses prototypes like JS.
		- Tables (associative arrays) seem like a very powerful idea and it'll be interesting to apply them in lua specific ways. There are some interesting design decisions around them that I want to explore in greater depth. And metatables just takes the idea to another level

- It might be a good idea for us to do a Lua cheatsheet that showcases key language features as we learn them.


[200416]

- Had a look at the C API, as documented in [Binding Code to Lua](http://lua-users.org/wiki/BindingCodeToLua) and [Official Lua Manual](https://www.lua.org/manual/5.1/manual.html#3). The latter has very useful examples.
    - First import headers: basic C API (`lua.h`, which provides primitive functions for interactions between C and Lua) and auxiliary library (`lauxlib.h`, which provides higher-level functions) using `#include`.
    - Lua uses a virtual stack for passing values to and from C. Each stack element is a number, string, etc. in Lua.
		- Several functions for getting items in the stack and pushing onto the stack, e.g. `void lua_pushinteger (lua_State *L, lua_Integer n)`.
		- API queries can use an index to reference different stack values (TOS has index 1). It appears to be more like a list than a stack.
    - Calling functions: `void lua_call (lua_State *L, int nargs, int nresults)` invokes a Lua function.
		- First, the function to-be-called is pushed onto the stack.
		- Next, its arguments (`nargs` of them) are pushed onto the stack (first argument is pushed first).
		- Finally, we invoke `lua_call`.
		- All of the above are removed from the stack and the return values of the function (`nresults` of them) are pushed to the stack.
    - Seems like you need to do a lot of low-level management yourself, e.g. controlling stack overflow, garbage collection and memory allocation.
		- `lua_checkstack` can be used to grow the stack.
	- This might be helpful to look at in more depth: https://dcc.ufrj.br/~fabiom/lua/12APIBasics.pdf


- Compiled a set of resources to help in learning more about Lua:
	- Did a small tutorial [Learn Lua in 15 Minutes](http://tylerneylon.com/a/learn-lua/).
		- Ok, this took a little longer than 15 minutes because Lua is pretty different and interesting
		- Tyler shares awesome resources to check out next including the standard libraries that his tutorial doesn't cover... might go through these tomorrow as well as Lua's short reference that he recommends
	- Lua [course notes](https://dcc.ufrj.br/~fabiom/lua/), these accompany the official book but are free to access.
	- Here's the last free version of the book (for Lua 5.0) https://www.lua.org/pil/1.html.
	- The Lua [reference manual](https://www.lua.org/manual/5.3/).
	- *A Look at the Design of Lua* [acm dl](https://dl.acm.org/doi/abs/10.1145/3186277).
	- *Lua -- an Extensible Extension Language* https://www.lua.org/spe.html.
	- *The Implementation of Lua 5.0* https://www.lua.org/doc/jucs05.pdf.
	- *The Evolution of Lua* [acm dl](https://dl.acm.org/doi/abs/10.1145/1238844.1238846).

[200417]

- Lua resources following [Learn Lua in 15 Minutes](http://tylerneylon.com/a/learn-lua/).
	- Lua [short reference](http://lua-users.org/files/wiki_insecure/users/thomasl/luarefv51.pdf). Note: this is for version 5.1 and was last updated in 2009.
	- Lua [tutorial directory](http://lua-users.org/wiki/TutorialDirectory). Contains tutorials on all standard libraries.

- Thinking about what I want to write in Lua next week
	- Maybe a game in Lua? Lua game engines [gamefromscratch 2018](https://www.gamefromscratch.com/post/2018/09/06/Lua-Game-Engines.aspx). I think I would use [Leadworks](https://www.leadwerks.com/programming) for a 3d game or [Defold](https://defold.com/showcase/) for a 2d game. Of course it would be super simple! Just to have a fun context to write more code in Lua. Might be too much overhead.

- Comparing [Lua to Python](http://lua-users.org/wiki/LuaVersusPython) and comparing [Lua to JS](https://www.mediawiki.org/wiki/User:Sumanah/Lua_vs_Javascript) and [learning Lua v. JS](http://phrogz.net/lua/LearningLua_FromJS.html)

- I think the best way to learn is to write a program (of course this won't be completely in the lua style). It's a start using what I learned in the tutorial from yesterday. I wrote a quick command line tic tac toe game. Here's the [game](week0/tictactoe.lua)

- Wrote a command line memory word game to familiarize myself with Lua: [Lua memory game](week0/memory_puzzle.lua). Starting to get more comfortable with the syntax but still unsure of what constitutes the "Lua way" of writing code.

[200421]

- Troubleshooting workflow with teletype

- Profilers
	- Had a look at some of the profilers available for Lua (see [here](week1/lua-runtimes-and-profilers.md)).
		- Investigated the [pepperfish profiler](http://lua-users.org/wiki/PepperfishProfiler). The source code is [here](week1/pepperfish_profiler.lua).
	- Seems like most (if not all) of them are time-based (i.e. tells you how much time it takes to execute certain functions). Would be interesting to know if we can also investigate memory usage.
	- Doesn't seem very hard to write your own profiler. Might be interesting to experiment with.

[200423]

- Looked at more profilers (updated the [readme](readme.md)). Code is no longer maintained and required fixing.
- Investigated [Luapower](https://luapower.com), which is a distribution for [LuaJIT](https://luajit.org/install.html), [Terra](http://terralang.org/) and [OpenResty](https://openresty.org/en/).

[200515]

- Note: using this is as scratch space

Projects to get source code to analyze from:

[pix2pix](https://github.com/phillipi/pix2pix) by phililipi: Torch implementation of pix2pix.

[koreader](https://github.com/koreader/koreader) by koreader: ebook reader application (note: uses luajit).

[fairseq](https://github.com/facebookresearch/fairseq) by Facebook AI research: sequence-to-sequence learning toolkit for Torch (note: luajit recommended).

[lite](https://github.com/rxi/lite) by rxi: lightweight text editor.

[LuaRocks](https://github.com/luarocks/luarocks) by luarocks: package manager for Lua modules.

[LuaMidi](https://github.com/PedroAlvesV/LuaMidi) by PedroAlvesV: pure Lua lib for reading / writing MIDI files.

[lunamark](https://github.com/jgm/lunamark) by jgm: Lua lib for conversion between markup formats.

[anim8](https://github.com/kikito/anim8) by kikito: Animation library for LÖVE game engine.
