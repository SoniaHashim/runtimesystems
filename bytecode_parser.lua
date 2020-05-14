-- A bytecode parser for Lua 5.1
-- Usage: lua bytecode.luac

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
	{"ABC",  "ABx", "ABC",  "ABC",
    "ABC",  "ABx", "ABC",  "ABx",
    "ABC",  "ABC", "ABC",  "ABC",
    "ABC",  "ABC", "ABC",  "ABC",
    "ABC",  "ABC", "ABC",  "ABC",
    "ABC",  "ABC", "AsBx", "ABC",
    "ABC",  "ABC", "ABC",  "ABC",
    "ABC",  "ABC", "ABC",  "AsBx",
    "AsBx", "ABC", "ABC", "ABC",
    "ABx",  "ABC"}

opcode_descriptions =
	{"Copy a value between registers.",
	"Load a constant into a register.", 
	"Load a boolean into a register.",
	"Load nil values into a range of registers.",
    "Read an upvalue into a register.",  
    "Read a global variable into a register.", 
    "Read a table element into a register.",  
    "Write a register value into a global variable.",
    "Write a register value into an upvalue.",
    "Write a register value into a table element.", 
    "Create a new table.",  
    "Prepare an object method for calling.",
    "Perform an addition.",  
    "Perform a subtraction.", 
    "Perform a multiplication.",
    "Perform a division.",
    "Perform a remainder operation.",
    "Perform an exponentiation.", 
    "Perform a unary minus operation.",  
    "Perform a logical NOT operation.",
    "Calculate the length.",  
    "Concatenate a range of registers.", 
    "Unconditional jump.", 
    "Equality test.",
    "Less than test.",  
    "Less than or equal to test.", 
    "Boolean test with conditional jump.",  
    "Boolean test with conditional jump and assignment.",
    "Call a closure.",  
    "Perform a tail call.", 
    "Return from a function call.",  
    "Iterate a numeric for loop.",
    "Initialize a numeric for loop.",
    "Iterate a generic for loop", 
    "Set a list of array elements for a table.", 
    "Close a range of locals being used as upvalues.", 
    "Create a closure of a function prototype.",
    "Assign vararg function arguments to registers.",
	"ABC"}

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

function get_string(input_table, byte_table_pointer, string_size)
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
	source_name_size, byte_table_pointer = get_int(bytes, byte_table_pointer, size_t, endianness)
	source_name, byte_table_pointer = get_string(bytes, byte_table_pointer, source_name_size)
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
			A_register_index = tonumber(binary_instruction:sub(19, 26), 2)
			if instruction_type == "ABC" then
				C_register_index = tonumber(binary_instruction:sub(10, 18), 2)
				B_register_index = tonumber(binary_instruction:sub(1, 9), 2)
			elseif instruction_type == "ABx" then
				B_register_index = tonumber(binary_instruction:sub(1, 18), 2)
			else
				B_register_index = tonumber(binary_instruction:sub(1, 18), 2) - 131071
			end
			instruction_operands = A_register_index .. " " .. B_register_index
			if instruction_type == "ABC" then
				instruction_operands = instruction_operands .. " " .. C_register_index
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
				constant_string_size, byte_table_pointer = get_int(bytes, byte_table_pointer, size_t, endianness)
				constant_data, byte_table_pointer = get_string(bytes, byte_table_pointer, constant_string_size)
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
					varname_size, byte_table_pointer = get_int(bytes, byte_table_pointer, size_t, endianness)
					varname, byte_table_pointer = get_string(bytes, byte_table_pointer, varname_size)
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
					upvalue_size, byte_table_pointer = get_int(bytes, byte_table_pointer, size_t, endianness)
					upvalue, byte_table_pointer = get_string(bytes, byte_table_pointer, 3)
					print(upvalue)
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
	read_bytecode(arg[1])
else
	print("File " .. arg[1] .. " does not exist.")
end
