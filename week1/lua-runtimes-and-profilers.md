## Runtimes and profilers

### Notes

- Lua's bytecode interpreter is written in ANSI C.
- Lua is embedded using a stack-based C API (the stack is atypical e.g. can be indexed directly).
- Lua is compiled during run-time but it can also be done offline.
- Lua's virtual machine is register-based.
-  [Here](http://lua-users.org/wiki/LuaDistributions) is a list of Lua distributions.
- [Here](http://lua-users.org/wiki/ProfilingLuaCode) is a list of Lua profilers.
- [Here](http://lua-users.org/wiki/OptimisationTips) are some ideas for optimizing Lua code.

### The Lua Virtual Machine

### Lua Byte Code

### Interpreter

`lua.c`

### Compiler

`luac.c`

### Profilers
