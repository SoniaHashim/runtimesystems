-- Test the Pepperfish and ProfilerInLua profilers for a simple Lua program.

require("pepperfish_profiler")
require("profiler_in_lua")

function loop()
  for i=1,10000 do
    for j = 1,10000 do
      local k = i + j
    end
  end
  return
end

-- Pepperfish

profiler = newProfiler("time")
profiler:start()
loop()
profiler:stop()
local outfile = io.open("profile.txt", "w+")
profiler:report(outfile)
outfile:close()

-- ProfilerInLua

Profiler:activate()
Profiler:deactivate()
Profiler:print_results()

