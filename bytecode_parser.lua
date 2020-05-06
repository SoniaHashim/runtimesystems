-- A bytecode parser for Lua 5.1
-- Usage: lua bytecode.luac

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

function get_int(input, int_size) -- construct in reverse order (is this correct?)
	return_int = ""
	for i = int_size, 1, -1 do
		return_int = return_int .. input[i]
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

function decode_header(bytes_table)
	print("The Lua version number is " .. bytes_table[5]:sub(1, 1) .. "." .. bytes_table[5]:sub(2, 2) .. ".")
	endianness_string = "big" -- 0 represents big endian
	if tonumber(bytes_table[7], 16) == 1 then
		endianness_string = "little" -- 1 represents little endian
	end
	endianness = tonumber(bytes_table[7], 16)
	size_int = tonumber(bytes_table[8], 16)
	size_t = tonumber(bytes_table[9], 16)
	size_instruction = tonumber(bytes_table[10], 16)
	size_lua_number = tonumber(bytes_table[11], 16)
	print("Endianness: " .. endianness_string .. " endian.")
	print("int: " .. size_int .. " bytes.")
	print("size_t: " .. size_t .. " bytes.")
	print("Instruction: " .. size_instruction .. " bytes.")
	print("lua_Number: " .. size_lua_number .. " bytes.")
	return endianness, size_int, size_t, size_instruction, size_lua_number
end

function decode_function(bytes, endianness, size_int, size_t, size_instruction, size_lua_number)
	source_name_size = get_int(split_table(bytes, 13, #bytes), size_int)
	source_name = get_string(split_table(bytes, 13 + size_int, #bytes), source_name_size)
	print(source_name)
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
		decode_function(bytes, endianness, size_int, size_t, size_instruction, size_lua_number)	
	end
end

if #arg ~= 1 then
	print("Usage: " .. arg[0] .. " <bytecode_file.luac>")
elseif file_exists(arg[1]) then
	read_bytecode(arg[1])
else
	print("File " .. arg[1] .. " does not exist.")
end
