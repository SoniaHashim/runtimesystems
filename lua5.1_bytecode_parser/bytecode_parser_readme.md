## Lua Bytecode Parser

Provides a human-readable interpretation of bytecode instructions.

### Requirements
- Written in Lua 5.3 for Lua 5.1 bytecode.
- The parser will not work correctly if executed with older versions of Lua.

### Usage
- Running: `lua5.3 bytecode_parser.lua bytecode_file.luac`
- Compiling your own Lua 5.1 bytecode: `luac5.1 -o bytecode_file.luac -s source_file.lua`

### Sample Bytecode
- File listing:
  - [`test_code_1.luac`](test_bytecode/test_code_1.luac) (demonstrates for loops).
  - [`test_code_1_v5.3.luac`](test_bytecode/test_code_v5.3.luac) (correctly aborts because of wrong version).
  - [`test_code_2.luac`](test_bytecode/test_code_2.luac) (demonstrates if-else statements).
  - [`test_code_3.luac`](test_bytecode/test_code_3.luac) (demonstrates table creation).
  - [`test_code_4.luac`](test_bytecode/test_code_4.luac) (demonstrates vararg functions).
- Corresponding source code is included. The bytecode was compiled from source on an x86 architecture (note that Lua bytecode is architecture dependent).
