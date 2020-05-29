-- To generate bytecode: luac5.1 -o test_code_1.luac -s $1
function execute_for_loop(lower, upper)
	for i = lower, upper do
		print(i*i + i)
	end
	return 1
end

execute_for_loop(1, 5)
print("For loop success!")