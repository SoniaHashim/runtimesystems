-- Test the pepperfish profiler for a simple Lua program.

require("pepperfish_profiler")

profiler = newProfiler()

function hello_world()
  print("Hello World!")
end

profiler:start()
os.execute("sleep 5")
hello_world()
profiler:stop()

local outfile = io.open("profile.txt", "w+")
profiler:report(outfile)
outfile:close()
