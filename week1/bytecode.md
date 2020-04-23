## Lua Bytecode

#### Notes

- The only official spec is for the Lua language. The VM instruction set can change from version to version
- The Lua VM is register based that translates to using a fixed portion of the stack (a frame) and instead of pushing or popping accessing constant register numbers
- Lua is not focused on performance -- the C API exposes bindings that can be used if that's the intended application (aka not meant to support extensive optimization)
- The intermediate representation is (unsurprisingly) in C

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
- C is in between A and B... kind of interesting
- A, B, C usually refer to register numbers where each register is an index to the current stack
- Lua compiles in chunks (chunk ::= block, basic set of statements in the language). See [Section 3.3.2](https://www.lua.org/manual/5.3/manual.html#3.3.2) of the Lua 5.3 reference manual). A chunk can be understood as the body of an anonymous function. It is compiled in the scope an external local var called `_ENV`. The functions `string.dump()`, `load` and `loadfile` can be used to go between different representations of a chunk.
	> To execute a chunk, Lua first loads it, precompiling the chunk's code into instructions for a virtual machine, and then Lua executes the compiled code with an interpreter for the virtual machine
	>Programs in source and compiled forms are interchangeable; Lua automatically detects the file type and acts accordingly

## Opcodes

```
/*----------------------------------------------------------------------
name            args    description
------------------------------------------------------------------------*/
OP_MOVE,/*      A B     R(A) := R(B)                                    */
OP_LOADK,/*     A Bx    R(A) := Kst(Bx)                                 */
OP_LOADKX,/*    A       R(A) := Kst(extra arg)                          */
OP_LOADBOOL,/*  A B C   R(A) := (Bool)B; if (C) pc++                    */
OP_LOADNIL,/*   A B     R(A), R(A+1), ..., R(A+B) := nil                */
OP_GETUPVAL,/*  A B     R(A) := UpValue[B]                              */

OP_GETTABUP,/*  A B C   R(A) := UpValue[B][RK(C)]                       */
OP_GETTABLE,/*  A B C   R(A) := R(B)[RK(C)]                             */

OP_SETTABUP,/*  A B C   UpValue[A][RK(B)] := RK(C)                      */
OP_SETUPVAL,/*  A B     UpValue[B] := R(A)                              */
OP_SETTABLE,/*  A B C   R(A)[RK(B)] := RK(C)                            */

OP_NEWTABLE,/*  A B C   R(A) := {} (size = B,C)                         */

OP_SELF,/*      A B C   R(A+1) := R(B); R(A) := R(B)[RK(C)]             */

OP_ADD,/*       A B C   R(A) := RK(B) + RK(C)                           */
OP_SUB,/*       A B C   R(A) := RK(B) - RK(C)                           */
OP_MUL,/*       A B C   R(A) := RK(B) * RK(C)                           */
OP_MOD,/*       A B C   R(A) := RK(B) % RK(C)                           */
OP_POW,/*       A B C   R(A) := RK(B) ^ RK(C)                           */
OP_DIV,/*       A B C   R(A) := RK(B) / RK(C)                           */
OP_IDIV,/*      A B C   R(A) := RK(B) // RK(C)                          */
OP_BAND,/*      A B C   R(A) := RK(B) & RK(C)                           */
OP_BOR,/*       A B C   R(A) := RK(B) | RK(C)                           */
OP_BXOR,/*      A B C   R(A) := RK(B) ~ RK(C)                           */
OP_SHL,/*       A B C   R(A) := RK(B) << RK(C)                          */
OP_SHR,/*       A B C   R(A) := RK(B) >> RK(C)                          */
OP_UNM,/*       A B     R(A) := -R(B)                                   */
OP_BNOT,/*      A B     R(A) := ~R(B)                                   */
OP_NOT,/*       A B     R(A) := not R(B)                                */
OP_LEN,/*       A B     R(A) := length of R(B)                          */

OP_CONCAT,/*    A B C   R(A) := R(B).. ... ..R(C)                       */

OP_JMP,/*       A sBx   pc+=sBx; if (A) close all upvalues >= R(A - 1)  */
OP_EQ,/*        A B C   if ((RK(B) == RK(C)) ~= A) then pc++            */
OP_LT,/*        A B C   if ((RK(B) <  RK(C)) ~= A) then pc++            */
OP_LE,/*        A B C   if ((RK(B) <= RK(C)) ~= A) then pc++            */

OP_TEST,/*      A C     if not (R(A) <=> C) then pc++                   */
OP_TESTSET,/*   A B C   if (R(B) <=> C) then R(A) := R(B) else pc++     */

OP_CALL,/*      A B C   R(A), ... ,R(A+C-2) := R(A)(R(A+1), ... ,R(A+B-1)) */
OP_TAILCALL,/*  A B C   return R(A)(R(A+1), ... ,R(A+B-1))              */
OP_RETURN,/*    A B     return R(A), ... ,R(A+B-2)      (see note)      */

OP_FORLOOP,/*   A sBx   R(A)+=R(A+2);
                        if R(A) <?= R(A+1) then { pc+=sBx; R(A+3)=R(A) }*/
OP_FORPREP,/*   A sBx   R(A)-=R(A+2); pc+=sBx                           */

OP_TFORCALL,/*  A C     R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));  */
OP_TFORLOOP,/*  A sBx   if R(A+1) ~= nil then { R(A)=R(A+1); pc += sBx }*/

OP_SETLIST,/*   A B C   R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B        */

OP_CLOSURE,/*   A Bx    R(A) := closure(KPROTO[Bx])                     */

OP_VARARG,/*    A B     R(A), R(A+1), ..., R(A+B-2) = vararg            */

OP_EXTRAARG/*   Ax      extra (larger) argument for previous opcode     */
```
- This resource [[1](https://the-ravi-programming-language.readthedocs.io/en/latest/lua_bytecode_reference.html)] explains each op code instruction in detail as well as the notation (e.g. R(A) register A specified in field A)

- This resource [[5](https://blog.tst.sh/lua-5-2-5-3-bytecode-reference-incomplete/)] provides a simple walkthrough of each instruction. I recommend using this one!

### Lua Bytecode

- The lua compiler (luac.c) can be used to just parse the source into bytecode. E.g. run `luac -l -l -p helloworld.lua`

- If you're curious here's what you'd get (using our version of [helloworld.lua](../week0/helloworld.lua))

```
main <helloworld.lua:0,0> (4 instructions at 0x7fa1d6c022d0)
0+ params, 2 slots, 1 upvalue, 0 locals, 2 constants, 0 functions
	1	[11]	GETTABUP 	0 0 -1	; _ENV "print"
	2	[11]	LOADK    	1 -2	; "Hello World"
	3	[11]	CALL     	0 2 1
	4	[11]	RETURN   	0 1
constants (2) for 0x7fa1d6c022d0:
	1	"print"
	2	"Hello World"
locals (0) for 0x7fa1d6c022d0:
upvalues (1) for 0x7fa1d6c022d0:
	0	_ENV	1	0
```

- 

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

[4] [Source (5.3) -- lopcodes.h, lopcodes.c](https://www.lua.org/source/5.3/)

[5] [PixelToast -- 5.2/5.3 bytecode reference](https://blog.tst.sh/lua-5-2-5-3-bytecode-reference-incomplete/)

[6] [Lua 5.2 Bytecode and Virtual Machine](http://files.catwell.info/misc/mirror/lua-5.2-bytecode-vm-dirk-laurie/lua52vm.html)
