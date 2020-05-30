-- To generate bytecode: luac5.1 -o test_code_4.luac -s $1

function vararg_function_1(...)
	print("Testing the first vararg function with input: " .. ... .. ".")
end

function vararg_function_2(...)
  print("Testing the second vararg function with input: " .. arg .. ".")
end

function vararg_function_3(...)
  print("Am I really a vararg function?")
end

function boring_function(input)
	print("Testing the boring function with input: " .. input .. ".")
end

vararg_function_1("my first input")
vararg_function_2("my second input")
vararg_function_3("my third input")
boring_function("my fourth input")