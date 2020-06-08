global_var = 25.93
-- the float 25.93 itself only appears in the main method constants list
-- the string "global_var" appears in the other two constants lists
function first_function()
	local var_1 = -50
	local var_2 = 100
	local var_3 = -200
	print(global_var)
	function second_function() -- I have three upvalues
		return global_var + var_1 + var_2 + var_3
	end
end
