## Lua Bytecode

#### Notes

- The only official spec is for the Lua language. The VM instruction set can change from version to version
- The Lua VM is register based
- Lua is not focused on performance -- the C API exposes bindings that can be used if that's the intended application (aka not meant to support extensive optimization)
-  


## Instructions
- 32 bit ixed size instructions
- 32 bit unsigned integer data type is the default.
- The first 6 bits contain the instruction opcode
- Instructions may be comprised of the following:
```
	'A'   : 8 bits
	'B'   : 9 bits
	'C'   : 9 bits
	'Ax'  : 26 bits ('A', 'B', and 'C' together)
	'Bx'  : 18 bits ('B' and 'C' together)
	'sBx' : signed Bx

```
- Signed args are given as the unsigned value minus K (K = max value for that arg which is half max for unsigned version of that arg). Note: -max = 0, +max = 2*max.



### Decompilers for Lua 5.3

[LuaDec](https://github.com/viruscamp/luadec)
-- Note: This decompiler is experimental for 5.3

[ChunkySpy](http://chunkspy.luaforge.net/)

[Unluac](https://sourceforge.net/projects/unluac/) -- Note: This decompiler is experimental for 5.3

[LuaDiassemblerAssembler](https://github.com/Altenius/LuaDisAss)

### Sources

[1] [Ravi Programming Language: Lua 5.3 Bytecode Reference](https://the-ravi-programming-language.readthedocs.io/en/latest/lua_bytecode_reference.html)

[2] [A No-Frills Introduction to Lua 5.1 VM Instructions](http://luaforge.net/docman/83/98/ANoFrillsIntroToLua51VMInstructions.pdf)

[3] [Notes on the Implementation of Lua 5.3](https://poga.github.io/lua53-notes/introduction.html)


[4] [Source (5.3) -- lopcodes.h](https://www.lua.org/source/5.3/lopcodes.h.html)

[5] [PixelToast -- 5.2/5.3 bytecode reference](https://blog.tst.sh/lua-5-2-5-3-bytecode-reference-incomplete/)
