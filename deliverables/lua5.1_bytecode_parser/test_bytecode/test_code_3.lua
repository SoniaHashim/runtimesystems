function make_table(input_1, input_2, input_3)
	local test_local_var = "local is cool"
	my_new_table = {}
	my_new_table[1] = input_1
	my_new_table[2] = input_2
	my_new_table[3] = input_3
	return my_new_table, test_local_var
end

new_table, local_variable = make_table("gwyneth", "was", "here")