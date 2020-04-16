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
		- Tables (associative arrays) seem like a very powerful idea and it'll be interesting to apply them in lua specific ways. There are some interesting design decisions around them that I want to explore in greater depth. And metatables just takes the idea to another level
		- 
- It might be a good idea for us to do a Lua cheatsheet that showcases key language features as we learn them.
