-- Test the pepperfish profiler for a simple Lua program.

require("pepperfish_profiler")

profiler = newProfiler()

function hello_world()
  print("Hello World!")
end

profiler:start()
hello_world()
profiler:stop()
