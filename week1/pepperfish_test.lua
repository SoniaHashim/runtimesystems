-- Test the pepperfish profiler for a simple Lua program.

require("pepperfish_profiler")

function loop()
  for i=1,1000 do
    for j = 1,1000 do
      local k = i + j
    end
  end
  return
end

profiler = newProfiler("time")
profiler:start()
loop()
profiler:stop()

local outfile = io.open("profile.txt", "w+")
profiler:report(outfile)
outfile:close()
