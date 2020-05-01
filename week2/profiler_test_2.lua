-- Test the Pepperfish and ProfilerInLua profilers for a simple Lua program.

require("pepperfish_profiler")

function add_two(x, y)
  return x + y
end

-- This checks for divisors in a stupid sort of way.
function switch_case(x)
	for i = x-1,2,-1 do
		if x%i == 0 then
			return add_two(x, i)
		end
	end
	return -1
end

-- Pepperfish

profiler = newProfiler("time")
profiler:start()
for i = 1,100000000 do
  local sum = add_two(i, i)
end
profiler:stop()
local outfile = io.open("profile_results_1.txt", "w+")
profiler:report(outfile)
outfile:close()

profiler = newProfiler("time")
profiler:start()
print(switch_case(99999989)) -- This is a prime number.
profiler:stop()
local outfile = io.open("profile_results_2.txt", "w+")
profiler:report(outfile)
outfile:close()



