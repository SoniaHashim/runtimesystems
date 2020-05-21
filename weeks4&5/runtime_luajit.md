# LuaJIT Runtime

## Overview
- There are 98 opcodes for the Lua bytecode
- Mixed-mode compilation with an interpreter and tracing JIT compiler
- Includes foreign function interface (ffi) to directly call C functions
- Garbage collection uses mark and sweep
- The intermediate representation is in Static Single Assignment form

## Instructions
- Instructions are 32 bits
- Opcodes take up an 8 bit field
- Instructions are of the format
```
	B	C	A	OP
	D		A	OP
```
- Operands can be the following:
	- var (var slot #), dst (var slot # used as destination), base (read-write base slot #), rbase (read-onlly base slot #), uv (upvalue), lit (literal), lits (signed literal), pri (primitive; 0 = nil, 1 = false, 2 = true), num (numeric constant), str (string constant), tab (template table), func (function prototype), cdata (cdata constant), jump (relative branch target)
	- pri, num, str, tab, func, cdata are indexes into the constant table
- Suffix distinguishes variation (V = variable slot, S = string constant, N = numeric constant, P = primitive, B = unsigned byte literal, M = multiple args)
### Opcodes
```
-- Comparison Opcodes
OP		A	D	Description
ISLT	var	var	Jump if A < D
ISGE	var	var	Jump if A ≥ D
ISLE	var	var	Jump if A ≤ D
ISGT	var	var	Jump if A > D
ISEQV	var	var	Jump if A = D
ISNEV	var	var	Jump if A ≠ D
ISEQS	var	str	Jump if A = D
ISNES	var	str	Jump if A ≠ D
ISEQN	var	num	Jump if A = D
ISNEN	var	num	Jump if A ≠ D
ISEQP	var	pri	Jump if A = D
ISNEP	var	pri	Jump if A ≠ D

-- Unary Test and Copy Opcodes
OP		A	D	Description
ISTC	dst	var	Copy D to A and jump, if D is true
ISFC	dst	var	Copy D to A and jump, if D is false
IST	 	var	Jump if D is true
ISF	 	var	Jump if D is false

-- Unary Opcodes
OP		A	D	Description
MOV		dst	var	Copy D to A
NOT		dst	var	Set A to boolean not of D
UNM		dst	var	Set A to -D (unary minus)
LEN		dst	var	Set A to #D (object length)

-- Binary Opcodes
OP		A		B 		C		Description
ADDVN	dst		var		num		A = B + C
SUBVN	dst		var		num		A = B - C
MULVN	dst		var		num		A = B * C
DIVVN	dst		var		num		A = B / C
MODVN	dst		var		num		A = B % C
ADDNV	dst		var		num		A = C + B
SUBNV	dst		var		num		A = C - B
MULNV	dst		var		num		A = C * B
DIVNV	dst		var		num		A = C / B
MODNV	dst		var		num		A = C % B
ADDVV	dst		var		var		A = B + C
SUBVV	dst		var		var		A = B - C
MULVV	dst		var		var		A = B * C
DIVVV	dst		var		var		A = B / C
MODVV	dst		var		var		A = B % C
POW		dst		var		var		A = B ^ C
CAT		dst		rbase	rbase	A = B .. ~ .. C

-- Constant Opcodes
OP		A		D		Description
KSTR	dst		str		Set A to string constant D
KCDATA	dst		cdata	Set A to cdata constant D
KSHORT	dst		lits	Set A to 16 bit signed integer D
KNUM	dst		num		Set A to number constant D
KPRI	dst		pri		Set A to primitive D
KNIL	base	base	Set slots A to D to nil

-- Upvalue and Function Opcodes
OP		A		D		Description
UGET	dst		uv		Set A to upvalue D
USETV	uv		var		Set upvalue A to D
USETS	uv		str		Set upvalue A to string constant D
USETN	uv		num		Set upvalue A to number constant D
USETP	uv		pri		Set upvalue A to primitive D
UCLO	rbase	jump	Close upvalues for slots ≥ rbase and jump to target D
FNEW	dst		func	Create new closure from prototype D and store it in A

-- Table ops
OP		A	B 	C	Description
TNEW	dst		lit	Set A to new table with size D (see below)
TDUP	dst		tab	Set A to duplicated template table D
GGET	dst		str	A = _G[D]
GSET	var		str	_G[D] = A
TGETV	dst	var	var	A = B[C]
TGETS	dst	var	str	A = B[C]
TGETB	dst	var	lit	A = B[C]
TSETV	var	var	var	B[C] = A
TSETS	var	var	str	B[C] = A
TSETB	var	var	lit	B[C] = A
TSETM	base	num*	(A-1)[D], (A-1)[D+1], ... = A, A+1, ...

-- Calls and Vararg Handling
OP		A		B	C/D	Description
CALLM	base	lit	lit	Call: A, ..., A+B-2 = A(A+1, ..., A+C+MULTRES)
CALL	base	lit	lit	Call: A, ..., A+B-2 = A(A+1, ..., A+C-1)
CALLMT	base		lit	Tailcall: return A(A+1, ..., A+D+MULTRES)
CALLT	base		lit	Tailcall: return A(A+1, ..., A+D-1)
ITERC	base	lit	lit	Call iterator: A, A+1, A+2 = A-3, A-2, A-1; A, ..., A+B-2 = A(A+1, A+2)
ITERN	base	lit	lit	Specialized ITERC, if iterator function A-3 is next()
VARG	base	lit	lit	Vararg: A, ..., A+B-2 = ...
ISNEXT	base		jump	Verify ITERN specialization and jump

-- Returns
OP		A		D	Description
RETM	base	lit	return A, ..., A+D+MULTRES-1
RET		rbase	lit	return A, ..., A+D-2
RET0	rbase	lit	return
RET1	rbase	lit	return A

-- Loops and branches
OP		A		D		Description
FORI	base	jump	Numeric 'for' loop init
JFORI	base	jump	Numeric 'for' loop init, JIT-compiled
FORL	base	jump	Numeric 'for' loop
IFORL	base	jump	Numeric 'for' loop, force interpreter
JFORL	base	lit		Numeric 'for' loop, JIT-compiled
ITERL	base	jump	Iterator 'for' loop
IITERL	base	jump	Iterator 'for' loop, force interpreter
JITERL	base	lit		Iterator 'for' loop, JIT-compiled
LOOP	rbase	jump	Generic loop
ILOOP	rbase	jump	Generic loop, force interpreter
JLOOP	rbase	lit		Generic loop, JIT-compiled
JMP		rbase	jump	Jump

-- Function headers
OP		A		D	Description
FUNCF	rbase		Fixed-arg Lua function
IFUNCF	rbase		Fixed-arg Lua function, force interpreter
JFUNCF	rbase	lit	Fixed-arg Lua function, JIT-compiled
FUNCV	rbase		Vararg Lua function
IFUNCV	rbase		Vararg Lua function, force interpreter
JFUNCV	rbase	lit	Vararg Lua function, JIT-compiled
FUNCC	rbase		Pseudo-header for C functions
FUNCCW	rbase		Pseudo-header for wrapped C functions
FUNC*	rbase		Pseudo-header for fast functions
```
- Comparison ops fall through to instruction after the jump if false; otherwise jump to target if comparison is true
- UCLO (close upvalues) combined with jump
- For calls, C is 1 + number of fixed args, B is 1 + number of return values or 0 to return all results
- For returns, operand D is 1 + num results to return
- `break` and `goto` statements translated into unconditional JMP or UCLO instructions
- FORL, ITERL, LOOP do hotspot detection to trigger trace recording
- All for instructions check that loop hasn't reached stopping condition, if true loop body or JIT-compiled trace entered otherwise left by fall through to next instruction
- All ITER instructions check A is not nil, if true loop body or JIT-compiled trace entered
- Loop instructions are no-ops (they don't branch) and are only used by the JIT compiler to alter data-flow

## Control flow analysis

- All comparison opcodes
- UCLO
- Unary and test opcodes
- Loops and branches

## Intermediate Representation overview

- SSA (Each node defines a value)
- Linear, implicitly numbered based on array position
- Extensible instructions supported otherwise 2 operands for each instruction
- Each instruction has an output data type
- Incrementally generated & bidirectionally grown. Constants grow
- Snapshots used to save bytecode execution state to restore on trace exits
- IR isn't separated into high-level, mid-level, low-level

## Bytecode Optimizations

## Garbage Collection

## Tracing in LuaJIT

- LuaJIT traces tail-, up-, down- recursion.
- Cross-trace register coalescing.
- Nested loops run native -- one root trace for innermost loop, side trace for each outer loop.


## Innovative Users
(as highlighted by Mike Pall, see [lua-users](http://lua-users.org/lists/lua-l/2009-11/msg00089.html))


### Sources
[1] [LuaJIT Project Page](http://luajit.org/luajit.html)

[2] [LuaJIT Innovative Features](http://lua-users.org/lists/lua-l/2009-11/msg00089.html)

[3] [Tracing in LuaJIT](http://lambda-the-ultimate.org/node/3851#comment-57679)

[4] [LuaJIT Intermediate Representation](http://wiki.luajit.org/SSA-IR-2.0)

[5] [LuaJIT Bytecode](http://wiki.luajit.org/Bytecode-2.0)

[6] [LuaJIT Optimizations](http://wiki.luajit.org/Optimizations)

[7] [LuaJIT Numerical Computing Performance Guide](http://wiki.luajit.org/Numerical-Computing-Performance-Guide)
