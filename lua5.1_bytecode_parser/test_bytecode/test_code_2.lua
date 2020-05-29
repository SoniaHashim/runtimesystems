-- To generate bytecode: luac5.1 -o test_code_2.luac -s $1

function square(input)
	return input*input
end

function execute_if_else(input)
	if input < 10 then
		print("Less than 10.")
	elseif input > 10 then
		print("More than 10.")
	elseif input == 10 then
		print("Exactly 10.")
	end
	return square(input) -- example of tail call
end

execute_if_else(5)
execute_if_else(10)
execute_if_else(15)