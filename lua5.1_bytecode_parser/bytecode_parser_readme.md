## Lua Bytecode Parser

Provides a human-readable interpretation of bytecode instructions.

### Requirements
- Written in lua 5.3 for lua bytecode version 5.1.

### Usage
- Running: `lua5.3 bytecode_parser.lua bytecode_file.luac`
- Compiling your own lua bytecode: `luac5.1 -o bytecode_file.luac -s source_file.lua`
- For sample bytecode, see `test_code_1.luac`, `test_code_2.luac` and `test_code_1_v5.3.luac` (the latter correctly aborts because of wrong version). Corresponding source code is included.
