-- A bytecode parser for Lua 5.3
-- Usage: lua bytecode.luac

opcode_names = 
	{"MOVE", "LOADK", "LOADKX", "LOADBOOL", 
	"LOADNIL", "GETUPVAL", "GETTABUP", "GETTABLE", 
	"SETTABUP", "SETUPVAL", "SETTABLE", "NEWTABLE", 
	"SELF", "ADD", "SUB", "MUL", 
	"MOD", "POW", "DIV", "IDIV", 
	"BAND", "BOR", "BXOR", "SHL", 
	"SHR", "UNM", "BNOT", "NOT", 
	"LEN", "CONCAT", "JMP", "EQ", 
	"LT", "LE", "TEST", "TESTSET", 
	"CALL", "TAILCALL", "RETURN", "FORLOOP", 
	"FORPREP", "TFORCALL", "TFORLOOP", "SETLIST", 
	"CLOSURE", "VARARG", "EXTRAARG"}

opcode_types =
	{"iABC", "iABx", "iABx", "iABC", 
	"iABC", "iABC", "iABC", "iABC", 
	"iABC", "iABC", "iABC", "iABC", 
	"iABC", "iABC", "iABC", "iABC", 
	"iABC", "iABC", "iABC", "iABC",
    "iABC", "iABC", "iABC", "iABC", 
    "iABC", "iABC", "iABC", "iABC", 
    "iABC", "iABC", "iAsBx", "iABC", 
    "iABC", "iABC", "iABC", "iABC", 
    "iABC", "iABC", "iABC", "iAsBx",
    "iAsBx", "iABC", "iAsBx", "iABC", 
    "iABx", "iABC", "iAx"}

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
	print("The Lua version number is " .. bytes_table[6]:sub(1, 1) .. "." .. bytes_table[6]:sub(2, 2) .. ".")
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
