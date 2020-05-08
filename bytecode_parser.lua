-- A bytecode parser for Lua 5.1
-- Usage: lua bytecode.luac

--[[ 
TODO:
Figure out how to parse doubles.
Should be able to invoke Lua 5.1 bytecode compiler if the user inputs a source file.
Would be nice to have an interactive mode for parsing code that the user writes on the command line.
Code needs serious restructuring.
Output format is terrible.
Attempt a rewrite for Lua 5.2.
--]] 

opcode_names =
	{"MOVE",     "LOADK",     "LOADBOOL", "LOADNIL",
    "GETUPVAL", "GETGLOBAL", "GETTABLE", "SETGLOBAL",
    "SETUPVAL", "SETTABLE",  "NEWTABLE", "SELF",
    "ADD",      "SUB",       "MUL",      "DIV",
    "MOD",      "POW",       "UNM",      "NOT",
    "LEN",      "CONCAT",    "JMP",      "EQ",
    "LT",       "LE",        "TEST",     "TESTSET",
    "CALL",     "TAILCALL",  "RETURN",   "FORLOOP",
    "FORPREP",  "TFORLOOP",  "SETLIST",  "CLOSE",
    "CLOSURE",  "VARARG"}

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

function split_table(table, start_index, end_index)
	return_table = {}
	for i = start_index, end_index do
		return_table[#return_table + 1] = table[i]
	end
	return return_table
end

function convert_to_bits(decimal_num, endianness) -- could not find built-in function
    if type(decimal_num) ~= number then
    	decimal_num = tonumber(decimal_num)
    end
    binary_num = ""
    while decimal_num > 0 do
        rest = math.fmod(decimal_num, 2)
        if endianness == 0 then
        	binary_num = binary_num .. math.floor(rest)
        else
        	binary_num = math.floor(rest) .. binary_num
        end
        decimal_num = (decimal_num - rest) / 2
    end
    while #binary_num < 32 do -- add padding to the left of the number
    	binary_num = "0" .. binary_num
    end
    return binary_num -- returns in string format
end

function get_int(input, int_size, endianness)
	return_int = ""
	if not input then
		return nil
	end
	for i = 1, int_size do
		if not input[i] then
			return nil
		end
		if endianness == 0 then
			return_int = return_int .. input[i]
		else
			return_int = input[i] .. return_int
		end
	end
	return tonumber(return_int, 16)
end

function get_string(input, string_size)
	return_string = ""
	for i = 1, string_size - 1 do -- last character is a 0 (ignore)
		return_string = return_string .. string.char(tonumber(input[i], 16))
	end
	return return_string
end

function get_bytes(input)
	bytes = {}
	for i = 1, string.len(input) do
		bytes[#bytes + 1] = string.format("%02X", input:byte(i))
	end
	return bytes
end

function decode_header(bytes_table) -- nothing here is affected by endianness
	print("The Lua version number is " .. bytes_table[5]:sub(1, 1) .. "." .. bytes_table[5]:sub(2, 2) .. ".")
	-- big-endian: most significant bytes first
	-- little-endian: most significant bytes last
	endianness = tonumber(bytes_table[7], 16)
	endianness_string = "big" -- 0 represents big-endian
	if endianneess == 1 then
		endianness_string = "little" -- 1 represents little-endian
	end
	size_int = tonumber(bytes_table[8], 16)
	size_t = tonumber(bytes_table[9], 16)
	size_instruction = tonumber(bytes_table[10], 16)
	size_lua_number = tonumber(bytes_table[11], 16)
	-- add integral flag
	print("Endianness: " .. endianness_string .. " endian.")
	print("int: " .. size_int .. " bytes.")
	print("size_t: " .. size_t .. " bytes.")
	print("Instruction: " .. size_instruction .. " bytes.")
	print("lua_Number: " .. size_lua_number .. " bytes.")
	return endianness, size_int, size_t, size_instruction, size_lua_number
end

function decode_function(byte_table_pointer, bytes, endianness, size_int, size_t, size_instruction, size_lua_number)
	source_name_size = get_int(split_table(bytes, byte_table_pointer, #bytes), size_int, endianness)
	byte_table_pointer = byte_table_pointer + size_int
	source_name = get_string(split_table(bytes, byte_table_pointer, #bytes), source_name_size)
	byte_table_pointer = byte_table_pointer + source_name_size + size_int
	start_line = get_int(split_table(bytes, byte_table_pointer, #bytes), size_int, endianness)
	byte_table_pointer = byte_table_pointer + size_int
	end_line = get_int(split_table(bytes, byte_table_pointer, #bytes), size_int, endianness)
	byte_table_pointer = byte_table_pointer + size_int
	num_upvalues = tonumber(bytes[byte_table_pointer], 16)
	byte_table_pointer = byte_table_pointer + 1
	num_parameters = tonumber(bytes[byte_table_pointer], 16)
	byte_table_pointer = byte_table_pointer + 1
	is_vararg_flag = tonumber(bytes[byte_table_pointer], 16)
	byte_table_pointer = byte_table_pointer + 1
	max_stack_size = tonumber(bytes[byte_table_pointer], 16)
	byte_table_pointer = byte_table_pointer + 1
	num_instructions = get_int(split_table(bytes, byte_table_pointer, #bytes), size_int, endianness)
	byte_table_pointer = byte_table_pointer + size_int
	print("Source name: " .. source_name .. ".")
	print("Line defined: " .. start_line .. ".")
	print("Last line defined: " .. end_line .. ".")
	print("Number of upvalues: " .. num_upvalues .. ".")
	print("Number of parameters: " .. num_parameters .. ".")
	print("is_vararg_flag: " .. is_vararg_flag .. ".")
	print("Maximum stack size: " .. max_stack_size .. ".")
	print("Number of instructions: " .. num_instructions .. ".")
	if num_instructions > 0 then
		for i = 1, num_instructions do
			decimal_instruction = get_int(split_table(bytes, byte_table_pointer, #bytes), size_instruction, endianness)
			byte_table_pointer = byte_table_pointer + size_instruction
			binary_instruction = convert_to_bits(decimal_instruction, endianness)
			-- opcodes are the first (least significant) six bits
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
			print("Binary representation of instruction: " .. binary_instruction)
			print("Opcode: " .. decimal_opcode)
			-- +1 for table lookup because instruction numbers start at zero
			print("Instruction name: " .. opcode_names[decimal_opcode + 1])
			print("Instruction type: " .. instruction_type)
			print("Instruction description: " .. opcode_descriptions[decimal_opcode + 1])
			print("Index A in R[A]: " .. A_register_index)
			print("Index B in R[B]: " .. B_register_index)
			if instruction_type == "ABC" then
				print("Index C in R[C]: " .. C_register_index)
			end
		end
		-- moving on to the constants
		num_constants = get_int(split_table(bytes, byte_table_pointer, #bytes), size_int, endianness)
		byte_table_pointer = byte_table_pointer + size_int
		print("Number of constants: " .. num_constants)
		for i = 1, num_constants do
			-- +1 for table lookup because constant numbers start at zero
			constant_type = constant_types[tonumber(bytes[byte_table_pointer], 16) + 1]
			byte_table_pointer = byte_table_pointer + 1
			print("Constant type: " .. constant_type)
			if constant_type == "LUA_TBOOLEAN" then
				-- unsure how large the data is
				constant_bool_value = tonumber(bytes[byte_table_pointer], 16)
				byte_table_pointer = byte_table_pointer + 1
				print("Constant boolean value: " .. constant_bool_value)
			elseif constant_type  == "LUA_TNUMBER" then
				--constant_number_value = get_int(split_table(bytes, byte_table_pointer, #bytes), size_lua_number, endianness)
				byte_table_pointer = byte_table_pointer + size_lua_number
				--print("Constant number value: " .. constant_number_value)
			elseif constant_type == "LUA_TSTRING" then
				-- why do I need to use size_lua_number instead of size_int to make this work?
				constant_string_size = get_int(split_table(bytes, byte_table_pointer, #bytes), size_lua_number, endianness)
				byte_table_pointer = byte_table_pointer + size_lua_number
				constant_string = get_string(split_table(bytes, byte_table_pointer, #bytes), constant_string_size)
				byte_table_pointer = byte_table_pointer + constant_string_size
				print("Constant string value: " .. constant_string)
			end -- LUA_TNIL has nothing
		end
		-- moving on to the function prototypes
		num_prototypes = get_int(split_table(bytes, byte_table_pointer, #bytes), size_int, endianness)
		byte_table_pointer = byte_table_pointer + size_int
		print("Number of function prototypes: " .. num_prototypes)
		for i = 1, num_constants do
			decode_function(byte_table_pointer, bytes, endianness, size_int, size_t, size_instruction, size_lua_number)
		end
	end
end

function read_bytecode(file)
	local bytecode_file = io.open(file, "rb")
	local bytecode_content = bytecode_file:read "*a" -- *a for the entire file
	bytecode_file:close()
	if bytecode_content:sub(1, 4) ~= "\x1bLua" then
		-- \xNN escape character: NN is a two-digit hex number
		print("The file " .. file .. " is not a Lua bytecode file.")
	else
		bytes = get_bytes(bytecode_content)
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
