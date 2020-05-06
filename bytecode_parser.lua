-- A bytecode parser for Lua 5.3
-- Usage: lua bytecode.luac

function file_exists(file)
  local f = io.open(file, "rb")
  if f then 
  	f:close() 
  end
  return f ~= nil
end

function read_bytecode(file)
	local bytecode_file = io.open(file, "rb")
	local bytecode_content = bytecode_file:read "*a" -- *a for the entire file
	bytecode_file:close()
end

if #arg ~= 1 then
	print("Usage: " .. arg[0] .. " <bytecode_file.luac>")
elseif file_exists(arg[1]) then
	read_bytecode(arg[1])
else
	print("File " .. arg[1] .. " does not exist.")
end
