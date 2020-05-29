-- A bytecode parser for Lua 5.1
-- Usage: lua $1 bytecode.luac

--[[ 
TODO:
Test extensively and compare output to other bytecode parsers.
Test on an architecture that uses big endian.
Should be able to invoke Lua 5.1 bytecode compiler if the user inputs a source file.
Would be nice to have an interactive mode for parsing code that the user writes on the command line.
Attempt a rewrite for Lua 5.2.
Attempt to document Lua 5.3 bytecode and rewrite.
Probably hard: actually produce the source code that the bytecode was constructed from.
--]] 

opcode_names =
	{"MOVE", "LOADK", "LOADBOOL", "LOADNIL",
    "GETUPVAL", "GETGLOBAL", "GETTABLE", "SETGLOBAL",
    "SETUPVAL", "SETTABLE", "NEWTABLE", "SELF",
    "ADD", "SUB", "MUL", "DIV",
    "MOD", "POW", "UNM", "NOT",
    "LEN", "CONCAT", "JMP", "EQ",
    "LT", "LE", "TEST", "TESTSET",
    "CALL", "TAILCALL", "RETURN", "FORLOOP",
    "FORPREP", "TFORLOOP", "SETLIST", "CLOSE",
    "CLOSURE", "VARARG"}

opcode_types =
	{"AB",  "ABx", "ABC",  "AB",
    "AB",  "ABx", "ABC",  "ABx",
    "AB",  "ABC", "ABC",  "ABC",
    "ABC",  "ABC", "ABC",  "ABC",
    "ABC",  "ABC", "AB",  "AB",
    "AB",  "ABC", "sBx", "ABC",
    "ABC",  "ABC", "AC",  "ABC",
    "ABC",  "ABC", "AB",  "AsBx",
    "AsBx", "AC", "ABC", "A",
    "ABx",  "AB"}

opcode_descriptions =
	{"\tCopy the value of register R(B) into register R(A).",
	"Load the constant number Kst(Bx) into register R(A).", 
	"Load the boolean value B into register R(A).\n\t\t\tIf C is nonzero, then skip the next instruction.",
	"Load nil values into the range of registers R(A) to R(B).",
    "Read the upvalue Up[B] into register R(A).",  
    "Read the value of the global variable Gbl[Kst(Bx)] into register R(A).", 
    "Read the table element R(B)[RK(C)] into register R(A).",  
    "Write the register value R(A) into the global variable Gbl[Kst(Bx)].",
    "Write the register value R(A) into the upvalue Up[B].",
    "Write the register value R(C) into the table element R(A)[RK(B)].", 
    "Create a new table at register R(A).\n\t\t\tB encodes the size of the array part and C the size of the hash part.",  
    "Load a function reference from the table element R(B)[RK(C)] into register R(A).\n\t\t\tLoad the table reference R(B) into register R(A+1).",
    "Load the sum of RK(B) and RK(C) into register R(A).",  
    "Load the difference of RK(B) and RK(C) into register R(A).", 
    "Load the product of RK(B) and RK(C) into register R(A).",
    "Load the quotient of RK(B) and RK(C) into register R(A).",
    "Load the result of RK(B) modulo RK(C) into register R(A).",
    "Load the result of RK(B) to the power RK(C) into register R(A).", 
    "Negate the value in register R(B) and load into register R(A).",  
    "Apply a boolean NOT to the value in register R(B).\n\t\t\tLoad the result into register R(A).",
    "Calculate the length of the object in register R(B).\n\t\t\tLoad the result into register R(A).",  
    "Concatenate the strings in the range of registers R(B) to R(C).\n\t\t\tLoad the result into register R(A).", 
    "\tPerform an unconditional jump (increment the program counter by sBx).", 
    "If the boolean result of RK(B) == RK(C) is not equal to A, then skip the next instruction.",
    "If the boolean result of RK(B) < RK(C) is not equal to A, then skip the next instruction.",  
    "If the boolean result of RK(B) <= RK(C) is not equal to A, then skip the next instruction.",  
    "Coerce register R(B) into a boolean and compare to boolean C.\n\t\t\tIf they match, then skip the next instruction.\n\t\t\tIf not, then load R(B) into R(A).", 
    "Coerce register R(A) into a boolean and compare to boolean C.\n\t\t\tIf they match, then skip the next instruction.",
    "Perform a function call.\n\t\t\tRegister R(A) holds the reference to the function object.\n\t\t\tThere are B-1 parameters and C-1 return values.", 
    "Perform a tail call (single function call in return statement). Register R(A) holds the reference to the function object with B-1 parameters. C is always zero.",
    "Return to the calling function.\n\t\t\tLoad B-1 return values into consecutive registers from R(A) onwards.",  
    "Iterate a numeric for loop.\n\t\t\tFor each iteration, the program counter is incremented by sBx.",
    "Initialize a numeric for loop.\n\t\t\tRegister R(A) holds the initial variable.\n\t\t\tR(A+1) holds the limit.\n\t\t\tR(A+2) holds the stepping value.\n\t\t\tR(A+3) holds the external index.",
    "Iterate a generic for loop.\n\t\t\tR(A) holds the iterator function (called once per loop).\n\t\t\tR(A+1) holds the state.\n\t\t\tR(A+2) holds the enumeration index.", 
    "Set the values for B array elements in a table referenced by R(A) starting at index C.", 
    "Close all local variables used as upvalues in the stack from register R(A) onwards.", 
    "Create a closure (instance) of a function prototype indexed by Bx.\n\t\t\tLoad the reference into register R(A).",
    "Load B-1 vararg function arguments into consecutive registers from R(A) onwards."}

constant_types = {"LUA_TNIL", "LUA_TBOOLEAN", "", "LUA_TNUMBER", "LUA_TSTRING"}
-- add a blank string that should never be reached (idiotic naming convention)

function file_exists(file)
  local f = io.open(file, "rb")
  if f then 
  	f:close() 
  end
  return f ~= nil
end

function convert_to_bits(decimal_num, num_total_bits) -- could not find built-in function
    -- this should not care about endianness
    -- we take care of that when reading in the decimal representation
    if type(decimal_num) ~= number then
    	decimal_num = tonumber(decimal_num)
    end
    is_signed = false
    if decimal_num < 0 then
    	is_signed = true
    	decimal_num = decimal_num*-1
    end
    binary_num = ""
    while decimal_num > 0 do
        rest = math.fmod(decimal_num, 2)
        binary_num = math.floor(rest) .. binary_num
        decimal_num = (decimal_num - rest) / 2
    end
    -- add padding to the left of the number
    while #binary_num < num_total_bits do
    	binary_num = "0" .. binary_num
    end
    if is_signed then
    	found_one = false
    	position_one = -1
    	for i = num_total_bits, 1, -1 do
    		if binary_num:sub(i, i) == "1" then
    			found_one = true
    			position_one = i
    			break
    		end
    	end
    	new_binary_num = binary_num:sub(position_one, num_total_bits)
    	if position_one ~= -1 then
	    	for i = position_one - 1, 1, -1 do
	    		if binary_num:sub(i, i) == "1" then
	    			new_binary_num = "0" .. new_binary_num
	    		else
	    			new_binary_num = "1" .. new_binary_num
	    		end
	    	end
	    	binary_num = new_binary_num
	    end
    end
    return binary_num -- returns in string format
end

function get_double_from_bits(bits) -- assumes string format
	sign = bits:sub(1, 1)
	exponent = tonumber(bits:sub(2, 12), 2) - 1023
	fraction = 1
	for i = 1, 52 do
		fraction = fraction + 2^(-i)*tonumber(bits:sub(12+i, 12+i))
	end
	return (-1)^sign * fraction * 2^exponent
end

function get_int(input_table, byte_table_pointer, int_size, endianness)
	return_int = ""
	if not input_table then
		return nil
	end
	for i = 1, int_size do
		if not input_table[byte_table_pointer+i-1] then
			return nil
		end
		if endianness == 0 then
			return_int = return_int .. input_table[byte_table_pointer+i-1]
		else
			return_int = input_table[byte_table_pointer+i-1] .. return_int
		end
	end
	return tonumber(return_int, 16), byte_table_pointer + int_size
end

function get_string(input_table, byte_table_pointer, size_t, endianness)
	string_size, byte_table_pointer = get_int(bytes, byte_table_pointer, size_t, endianness)
	return_string = ""
	for i = 1, string_size - 1 do -- last character is a 0 (ignore)
		return_string = return_string .. string.char(tonumber(input_table[byte_table_pointer+i-1], 16))
	end
	return return_string, byte_table_pointer + string_size
end

function get_byte(input_table, byte_table_pointer)
	return tonumber(bytes[byte_table_pointer], 16), byte_table_pointer + 1
end

function get_bytecode_as_bytes(input)
	bytes = {}
	for i = 1, string.len(input) do
		bytes[#bytes + 1] = string.format("%02X", input:byte(i))
	end
	return bytes
end

function print_initial_information()
	print("NOTATION USED")
	print("R(A):\t\t\tRegister A (specified in instruction field A).")
	print("R(B):\t\t\tRegister B (specified in instruction field B).")
	print("R(C):\t\t\tRegister C (specified in instruction field C).")
	print("RK(B):\t\t\tRegister B or an index into the list of constants.")
	print("RK(C):\t\t\tRegister C or an index into the list of constants.")
	print("sBx:\t\t\tSigned number (specified in instruction field sBx).")
	print("Bx:\t\t\tUnsigned number (specified in instruction field Bx).")
	print("Kst(n):\t\t\tElement n in the list of constants.")
	print("Gbl[n]:\t\t\tGlobal variable with symbolic index n.")
	print("Up[n]:\t\t\tName of the upvalue with index n.")
	print("----------------------------------------------------------------------------------------")
end

function decode_header(bytes_table) -- nothing here is affected by endianness
	print("HEADER INFORMATION")
	print("The Lua version number is " .. bytes_table[5]:sub(1, 1) .. "." .. bytes_table[5]:sub(2, 2) .. ".")
	-- big-endian: most significant bytes first
	-- little-endian: most significant bytes last
	endianness = tonumber(bytes_table[7], 16)
	endianness_string = "big" -- 0 represents big-endian
	if endianness == 1 then
		endianness_string = "little" -- 1 represents little-endian
	end
	size_int = tonumber(bytes_table[8], 16)
	size_t = tonumber(bytes_table[9], 16)
	size_instruction = tonumber(bytes_table[10], 16)
	size_lua_number = tonumber(bytes_table[11], 16)
	integral_flag = tonumber(bytes_table[12], 16)
	print("Endianness: " .. endianness_string .. " endian.")
	print("int: " .. size_int .. " bytes.")
	print("size_t: " .. size_t .. " bytes.")
	print("Instruction: " .. size_instruction .. " bytes.")
	print("lua_Number: " .. size_lua_number .. " bytes.")
	print("Integral flag: " .. integral_flag .. ".")
	return endianness, size_int, size_t, size_instruction, size_lua_number
end

function decode_function(byte_table_pointer, bytes, endianness, size_int, size_t, size_instruction, size_lua_number)
	print("----------------------------------------------------------------------------------------")
	print("CHUNK INFORMATION")
	source_name, byte_table_pointer = get_string(bytes, byte_table_pointer, size_t, endianness)
	start_line, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
	end_line, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
	num_upvalues, byte_table_pointer = get_byte(bytes, byte_table_pointer)
	num_parameters, byte_table_pointer = get_byte(bytes, byte_table_pointer)
	is_vararg_flag, byte_table_pointer = get_byte(bytes, byte_table_pointer)
	max_stack_size, byte_table_pointer = get_byte(bytes, byte_table_pointer)
	num_instructions, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
	print("Line defined: " .. start_line .. ".")
	print("Last line defined: " .. end_line .. ".")
	print("Number of upvalues: " .. num_upvalues .. ".")
	print("Number of parameters: " .. num_parameters .. ".")
	print("is_vararg_flag: " .. is_vararg_flag .. ".")
	print("Maximum stack size: " .. max_stack_size .. ".")
	print("Number of instructions: " .. num_instructions .. ".")
	print("--------------------------------------------------")
	if num_instructions > 0 then
		for i = 1, num_instructions do
			decimal_instruction, byte_table_pointer = get_int(bytes, byte_table_pointer, size_instruction, endianness)
			binary_instruction = convert_to_bits(decimal_instruction, 32)
			-- opcodes are the least significant six bits
			decimal_opcode = tonumber(binary_instruction:sub(27, 32), 2)
			instruction_type = opcode_types[decimal_opcode + 1]
			if instruction_type == "ABC" then
				A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
				B_register_index = tonumber(binary_instruction:sub(1, 9), 2)
				C_register_index = tonumber(binary_instruction:sub(10, 18), 2)
			elseif  instruction_type == "AB" then
				A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
				B_register_index = tonumber(binary_instruction:sub(1, 9), 2)
			elseif instruction_type == "AC" then
				A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
				C_register_index = tonumber(binary_instruction:sub(10, 18), 2)
			elseif instruction_type == "ABx" then
				A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
				B_register_index = tonumber(binary_instruction:sub(1, 18), 2)
			elseif instruction_type == "AsBx" then
				A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
				B_register_index = tonumber(binary_instruction:sub(1, 18), 2) - 131071
			elseif instruction_type == "sBx" then
				B_register_index = tonumber(binary_instruction:sub(1, 18), 2) - 131071
			else
				A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
			end
			if (instruction_type == "AB") or (instruction_type == "ABx") or (instruction_type == "AsBx") then
				instruction_operands = A_register_index .. " " .. B_register_index
			elseif instruction_type == "ABC" then
				instruction_operands = A_register_index .. " " .. B_register_index .. " " .. C_register_index
			elseif instruction_type == "AC" then
				instruction_operands = A_register_index .. " " .. C_register_index
			else
				instruction_operands = A_register_index
			end
			-- +1 for table lookup because instruction numbers start at zero
			print(opcode_names[decimal_opcode + 1] .. " " .. instruction_operands .. " (" .. instruction_type .. "): \t" .. opcode_descriptions[decimal_opcode + 1]) 
		end
		print("--------------------------------------------------")
		-- moving on to the constants
		num_constants, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
		print("Number of constants: " .. num_constants)
		for i = 1, num_constants do
			constant_type_index, byte_table_pointer = get_byte(bytes, byte_table_pointer)
			-- +1 for table lookup because constant numbers start at zero
			constant_type = constant_types[constant_type_index + 1]
			constant_data = ""
			if constant_type == "LUA_TBOOLEAN" then
				constant_data, byte_table_pointer = get_byte(bytes, byte_table_pointer)
			elseif constant_type  == "LUA_TNUMBER" then
				decimal_constant_number, byte_table_pointer = get_int(bytes, byte_table_pointer, size_lua_number, endianness)
				constant_number_bits = convert_to_bits(decimal_constant_number, 64)
				constant_data = get_double_from_bits(constant_number_bits)
			elseif constant_type == "LUA_TSTRING" then
				constant_data, byte_table_pointer = get_string(bytes, byte_table_pointer, size_t, endianness)
			else
				constant_data = "" -- LUA_TNIL has nothing
			end
			print(constant_type .. " " .. constant_data)
		end
		print("--------------------------------------------------")
		-- moving on to the function prototypes
		num_prototypes, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
		print("Number of function prototypes: " .. num_prototypes)
		if num_prototypes > 0 then
			byte_table_pointer = decode_function(byte_table_pointer, bytes, endianness, size_int, size_t, size_instruction, size_lua_number)
		end
		print("--------------------------------------------------")
		-- moving on to the (optional) source line position list
		print("Optional parts of chunk:")
		sizelineinfo, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
		if sizelineinfo then
			print("Size of source line positions list: " .. sizelineinfo)
			if sizelineinfo > 0 then
				for i = 1, sizelineinfo do
					source_line_position, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
				end
			end
		end
		-- moving on to the (optional) local variable list
		sizelocvars, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
		if sizelocvars then
			print("Size of locals list: " .. sizelocvars)
			if sizelocvars > 0 then
				for i = 1, sizelocvars do
					varname, byte_table_pointer = get_string(bytes, byte_table_pointer, size_t, endianness)
					startpc, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
					endpc, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
				end
			end
		end
		-- moving on to the (optional) upvalues list
		sizeupvalues, byte_table_pointer = get_int(bytes, byte_table_pointer, size_int, endianness)
		if sizeupvalues then
			print("Size of upvalues list: " .. sizeupvalues)
			if sizeupvalues > 0 then
				for i = 1, sizeupvalues do
					upvalue, byte_table_pointer = get_string(bytes, byte_table_pointer, size_t, endianness)
				end
			end
		end
		print("----------------------------------------------------------------------------------------")
	end
	return byte_table_pointer
end

function read_bytecode(file)
	local bytecode_file = io.open(file, "rb")
	local bytecode_content = bytecode_file:read "*a" -- *a for the entire file
	bytecode_file:close()
	if bytecode_content:sub(1, 4) ~= "\x1bLua" then
		-- \xNN escape character: NN is a two-digit hex number
		print("The file " .. file .. " is not a Lua bytecode file.")
	else
		bytes = get_bytecode_as_bytes(bytecode_content)
		endianness, size_int, size_t, size_instruction, size_lua_number = decode_header(bytes)
		decode_function(13, bytes, endianness, size_int, size_t, size_instruction, size_lua_number)	
	end
end

if #arg ~= 1 then
	print("Usage: " .. arg[0] .. " <bytecode_file.luac>")
elseif file_exists(arg[1]) then
	print_initial_information()
	read_bytecode(arg[1])
else
	print("File " .. arg[1] .. " does not exist.")
end
