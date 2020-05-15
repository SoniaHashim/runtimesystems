# Survey

## Lua Design & Evolution

1. *The design and implementation of a language for extending application*
by L. H. de Figueiredo, R. Ierusalimschy, W. Celes,
Proceedings of XXI Brazilian Seminar on Software and Hardware (1994) 273–283.
[reprint](http://www.lua.org/semish94.html)

2. *Lua: an extensible embedded language*
by L. H. de Figueiredo, R. Ierusalimschy, W. Celes,
Dr. Dobb's Journal 21 \#12 (Dec 1996) 26–33.
[reprint](http://www.lua.org/ddj.html)

3. *A Look at the Design of Lua*
by Roberto Ierusalimschy, Luiz Henrique De Figueiredo, Waldemar Celes
Communications of the ACM, November 2018, Vol. 61 No. 11, Pages 114-123
10.1145/3186277
[CACM](https://cacm.acm.org/magazines/2018/11/232214-a-look-at-the-design-of-lua/fulltext)

4. *The Evolution of Lua*
by R. Ierusalimschy, L. H. de Figueiredo, W. Celes
Proceedings of ACM HOPL III (2007) 2-1–2-26
[slides](http://www.inf.puc-rio.br/~roberto/talks/hopl-slides.pdf)
[paper](https://cacm.acm.org/magazines/2018/11/232214-a-look-at-the-design-of-lua/fulltext)

## LuaJIT

LuaJIT is a tracing just-in-time compiler that combines an interpreter and the tracing JIT compiler. LuaJIT also exposes an foreign function interface (ffi) to directly call C functions. Note: the wiki has good documentation of the internals including the [bytecode](http://wiki.luajit.org/Bytecode-2.0), [intermediate representation](http://wiki.luajit.org/SSA-IR-2.0), and [optimizations](http://wiki.luajit.org/Optimizations).

[Project Page](http://luajit.org/luajit.html)

 *LuaJIT 2.0 intellectual property disclosure and research opportunities* (Note: includes overview of design decisions.)
by Mike Pall
[lua-users](http://lua-users.org/lists/lua-l/2009-11/msg00089.html)

## Terra

Terra is designed as a low level companion language to Lua and can be meta-programmed in Lua. The use cases are very interesting and one that stands out is the ability to "compile domain specific languages (DSLs) written in Lua into high-performance Terra code" ([terralang.org](http://terralang.org/)).

[Project Page](http://terralang.org/)

1. *Terra: A Multi-Stage Language for High-Performance Computing*
by Z. DeVito, J. Hegarty, A. Aiken, P. Hanrahan, J. Vitek
PDLI '13
[paper](http://terralang.org/pldi071-devito.pdf)

2. *The Design of Terra: harnessing the best features of high-level and low-level languages*
by Z. DeVito, P. Hanrahan
SNAPL ‘15
[paper](https://cs.stanford.edu/~zdevito/snapl-devito.pdf)
