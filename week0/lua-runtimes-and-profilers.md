## Runtimes and profilers

### Notes

- Lua's bytecode interpreter is written in ANSI C.
- Lua is embedded using a stack based C API (the stack is atypical e.g. can be indexed directly)
- Lua is compiled during run-time but it can also be done offline
- Lua's virtual machine is register based
