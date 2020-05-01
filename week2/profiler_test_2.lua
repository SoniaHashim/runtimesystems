-- Test the Pepperfish and ProfilerInLua profilers for a simple Lua program.

require("pepperfish_profiler")

function add_two(x, y)
  return x + y
end

-- Pepperfish

profiler = newProfiler("time")
profiler:start()
for i = 1,100000000 do
  local sum = add_two(i, i)
end
profiler:stop()
local outfile = io.open("profile.txt", "w+")
profiler:report(outfile)
outfile:close()



