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

function get_bytes(input)
	bytes = {}
	for i = 1, string.len(input) do
		bytes[#bytes + 1] = string.format("%02X", input:byte(i))
	end
	return bytes
end

function get_header_info(bytes_table)
	print("The Lua version number is " .. bytes_table[5]:sub(1, 1) .. "." .. bytes_table[5]:sub(2, 2) .. ".")
	endianness_string = "big" -- 0 represents big endian
	if tonumber(bytes_table[7], 16) == 1 then
		endianness_string = "little" -- 1 represents little endian
	end
	print("Endianness: " .. endianness_string .. " endian.")
	print("int: " .. tonumber(bytes_table[8], 16) .. " bytes.")
	print("size_t: " .. tonumber(bytes_table[9], 16) .. " bytes.")
	print("Instruction: " .. tonumber(bytes_table[10], 16) .. " bytes.")
	print("lua_Number: " .. tonumber(bytes_table[11], 16) .. " bytes.")
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
		get_header_info(bytes)
	end
end

if #arg ~= 1 then
	print("Usage: " .. arg[0] .. " <bytecode_file.luac>")
elseif file_exists(arg[1]) then
	read_bytecode(arg[1])
else
	print("File " .. arg[1] .. " does not exist.")
end
