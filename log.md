## Daily Log

### Week 0 -- Intro to Lua

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
		- Ok this took a little longer than 15 minutes because Lua is pretty different and interesting
		- Tyler shares awesome resources to check out next including the standard libraries that his tutorial doesn't cover... might go through these tomorrow as well as Lua's short reference that he recommends 
	- Lua [course notes](https://dcc.ufrj.br/~fabiom/lua/), these accompany the official book but are free to access.
	- Here's the last free version of the book (for Lua 5.0) https://www.lua.org/pil/1.html.
	- The Lua [reference manual](https://www.lua.org/manual/5.3/).
	- *A Look at the Design of Lua* [acm dl](https://dl.acm.org/doi/abs/10.1145/3186277).
	- *Lua -- an Extensible Extension Language* https://www.lua.org/spe.html.
	- *The Implementation of Lua 5.0* https://www.lua.org/doc/jucs05.pdf.
	- *The Evolution of Lua* [acm dl](https://dl.acm.org/doi/abs/10.1145/1238844.1238846).
