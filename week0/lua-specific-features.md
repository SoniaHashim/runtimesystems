### Basic overview of Lua features and uses:

- Popular in the embedded and game development space.
- Lightweight, portable, extensible and easy for developers to learn and use.
- Lua 5.3.5 tarball is 297K compressed and 1.2M uncompressed with 24000 lines of C [[1]](https://www.lua.org/about.html).
- Dynamically typed.
- Cross-platform: Lua is first compiled into platform-independent bytecode, which is then executed on a Lua virtual machine. The compilation into bytecode is typically not seen by the user, but it can be performed from within Lua if desired. The interpreter (of the bytecode) is written in ANSI C.
- Unlike most VMs (which are stack-based), the Lua VM is register-based. Question: why this choice?
- Referred to as a "multi-paradigm" language: general features are provided with the intention of being adapted and extended for different kinds of problems. Consequently, the base language is lightweight (has a very small memory footprint) and minimalistic.
- Has a C API that can be used for embedding Lua into applications. Question: can I call Lua from other languages?
- Has a small number of atomic data structures (boolean values, integers, floating point numbers and strings) and a single native data structure: the table (hashed heterogeneous associative array). Tables can be used to implement common data structures such as arrays, lists and sets.
- Advanced features to investigate: first-class functions, garbage collection, closures, proper tail calls, coercion, coroutines and dynamic module loading.

### Advanced features

- *Garbage Collection*: Means provide automatic memory management (the alternative reference count is not used since it adds overhead to dynamically typed languages).
	- `x = nil` undefines x.
	- Garbage Collection in Lua [[slides](https://www.lua.org/wshop18/Ierusalimschy.pdf)]


- *First-class Functions*: functions support all operations that are generally available to other entities (including passing functions as arguments, using functions as function return values, modifying functions and assigning functions to variables). This means that functions are "first-class citizens", which is a necessary part of functional programming.

- *Dynamic Loading*: load a library into memory at run time (as opposed to static or dynamic linking). Unlike with dynamic linking: program can start up without these libraries or gain access to whatever libraries might be available.

### Applications and Common Uses

- Industrial apps including Adobe's Photoshop Lightroom
- Games including World of Warcraft and Angry Birds
- Blackmagic Fusion, post-production image compositing software
- Celestia, realt-time 3d visualization of space
- LuaTeX, TeX engine
- Common uses: config language for apps, scripting language, embedded language to modify runtime behavior

[1] https://www.lua.org/about.html.
