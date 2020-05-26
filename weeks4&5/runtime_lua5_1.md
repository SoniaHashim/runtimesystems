# Lua 5.1 Runtime

## Overview
- There are 38 opcodes
- The VM is register based (motivated by reducing number of instructions per function by avoiding copying -- i.e. push / pop on stack)
- Incremental garbage collection is used
- Each function represented as a prototype (includes array with opcodes, array of Lua values and constants)

## Instructions
- The first 6 bits contain the instruction opcode.
- 32 bit (4 byte) fixed size instructions
- 32 bit unsigned integer data type is the default.
- Instructions may be comprised of the following:
- Signed args represnted in excess K; num value is unsigned value minus K where K is the max value for that arg. (-max is given by 0, +max is 2*max)
```
	'A'   : 8 bits
	'B'   : 9 bits
	'C'   : 9 bits
	'Ax'  : 26 bits ('A', 'B', and 'C' together)
	'Bx'  : 18 bits ('B' and 'C' together)
	'sBx' : signed Bx

```

## Opcodes
- The operands of an opcode can be one of the following:  
	- R(x) = register
	- Kst(x) = constant (in the constant table)
	- RK(x) == if is K(x) then Kst(index of K(x)) else R(x)
- The given opcodes are as follows:
```
/*----------------------------------------------------------------------
name            args    description
------------------------------------------------------------------------*/
OP_MOVE,/*      A B     R(A) := R(B)                                    */
OP_LOADK,/*     A Bx    R(A) := Kst(Bx)                                 */
OP_LOADBOOL,/*  A B C   R(A) := (Bool)B; if (C) pc++                    */
OP_LOADNIL,/*   A B     R(A) := ... := R(B) := nil                      */
OP_GETUPVAL,/*  A B     R(A) := UpValue[B]                              */

OP_GETGLOBAL,/* A Bx    R(A) := Gbl[Kst(Bx)]                            */
OP_GETTABLE,/*  A B C   R(A) := R(B)[RK(C)]                             */

OP_SETGLOBAL,/* A Bx    Gbl[Kst(Bx)] := R(A)                            */
OP_SETUPVAL,/*  A B     UpValue[B] := R(A)                              */
OP_SETTABLE,/*  A B C   R(A)[RK(B)] := RK(C)                            */

OP_NEWTABLE,/*  A B C   R(A) := {} (size = B,C)                         */

OP_SELF,/*      A B C   R(A+1) := R(B); R(A) := R(B)[RK(C)]             */

OP_ADD,/*       A B C   R(A) := RK(B) + RK(C)                           */
OP_SUB,/*       A B C   R(A) := RK(B) - RK(C)                           */
OP_MUL,/*       A B C   R(A) := RK(B) * RK(C)                           */
OP_DIV,/*       A B C   R(A) := RK(B) / RK(C)                           */
OP_MOD,/*       A B C   R(A) := RK(B) % RK(C)                           */
OP_POW,/*       A B C   R(A) := RK(B) ^ RK(C)                           */
OP_UNM,/*       A B     R(A) := -R(B)                                   */
OP_NOT,/*       A B     R(A) := not R(B)                                */
OP_LEN,/*       A B     R(A) := length of R(B)                          */

OP_CONCAT,/*    A B C   R(A) := R(B).. ... ..R(C)                       */

OP_JMP,/*       sBx     pc+=sBx                                 */

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

OP_TFORLOOP,/*  A C     R(A+3), ... ,R(A+2+C) := R(A)(R(A+1), R(A+2));
                        if R(A+3) ~= nil then R(A+2)=R(A+3) else pc++   */
OP_SETLIST,/*   A B C   R(A)[(C-1)*FPF+i] := R(A+i), 1 <= i <= B        */

OP_CLOSE,/*     A       close all variables in the stack up to (>=) R(A)*/
OP_CLOSURE,/*   A Bx    R(A) := closure(KPROTO[Bx], R(A), ... ,R(A+n))  */

OP_VARARG/*     A B     R(A), R(A+1), ..., R(A+B-1) = vararg            */
```
- Additional notes on instructions:
	- For CALL and RETURN and SETLIST, if B == 0 then B = top
	- For CALL, C is number of returns -1
	- For SETLIST, if C == 0 then next instruction is C
	- For comparisons (EQ, LT, LE) A specifies if test accepts true or false
	- Skips (pc++) assume the next instruction is a jump
- return 0 1 instruction always added by code generator (never executes, wastes 4 bytes)
- CLOSURE followed by MOVE and GETUPVAL. MOVE corresponds to local var R(B) in current lexical block used as upvalue in instantiated function. GETUPVAL corresponds to upvalue number B

## Control Flow Analysis
- Lua 5.1
	- `jmp` unconditional jump
	- `eq` skip --> assumes jump
	- `le` skip --> assumes jump
	- `lt` skip --> assumes jump
	- `test` boolean test with conditional jump
	- `testset` boolean test with conditional jump and assignment
	- `loadbool` skip --> assumes jump
	- `forprep` skip --> assumes jump
	- `forloop` skip --> assumes jump
	- `tforloop` skip --> assumes jump
	- `call` call a closure
	- `tailcall` tailcall (effectively a goto avoids nesting) R(A) holds reference to function object to be called
	- `close` close a range of locals being used as upvalues
	- `closure` create closure of a function prototype
	- Comparisons `eq`, `le`, `lt`, `test`, `testset` fall through case always expects a `jmp` that is executed with the instruction above
	- Comparisons return a boolean, `loadbool` used to specify correct boolean value and jump to next instruction for conditional expressions not conditional statements (if C specified)
		- Example (`eq`, `lt`, `le`)
		```
		>local x,y; return x ~= y
		; function [0] definition (level 1)
		; 0 upvalues, 0 params, 3 stacks
		.function 0 0 0 3
		.local "x" ; 0
		.local "y" ; 1
		[1] loadnil 0 1
		[2] eq 0 0 1 ; to [4] if true (x ~= y)
		[3] jmp 1 ; to [5]
		[4] loadbool 2 0 1 ; false, to [6] (false result path)
		[5] loadbool 2 1 0 ; true (true result path)
		[6] return 2 2
		[7] return 0 1
		; end of function
		```
		- Explanation:
		```
		if x ~= y then
		 return true
		else
		 return false
		end
		```
- Numeric loops require 4 registers on the stack. R(A) is the internal loop index, R(A+1) is the limit, R(A+2) is stepping val, R(A+3) is loop variable. Jump made back to start of loop body if the limit has not been reached (if empty, sBx value = -1). Note sBx (jump) is negative.
- Forprep tests loop condition and conditional testing during loop, jumps unconditionally to forloop

## Garbage Collection
- Until 5.0 mark & sweep collector -- pauses in execution very long
- Interleaves execution of collector with main program.
- Tricolor collector
	- Non-visited objects (white), visited but not traversed (gray), traversed objects (black)
	- objects in root set gray or black
	- gray objects define boundary white and black objects
	- collection traverses gray objects and turns them black
	- collection ends when there are no more gray objects
- Mark phase ends with atomic step (traversing all gray objects again), clears weak tables
- Alternates with the mutator with pace controlled by how much memory has to grow before starting new cycle and multiplier (translation of bytes to GC work)
- Generational collector
	- Minor collection, collector traverses and sweeps only young objects (since most objects die young)
	- Touched object if black barrier detects old object pointing to a new one (goes back to normal after 2 cycles unless touched again)


### Sources

[1] [Source (5.1) -- lopcodes.h, lopcodes.c](https://www.lua.org/source/5.1/)

[2] [A No-Frills Introduction to Lua 5.1 VM Instructions](http://luaforge.net/docman/83/98/ANoFrillsIntroToLua51VMInstructions.pdf)

[3] [The Implementation of Lua 5.0](https://www.lua.org/doc/jucs05.pdf)

[4] [Garbage Collection in Lua](https://www.lua.org/wshop18/Ierusalimschy.pdf)
