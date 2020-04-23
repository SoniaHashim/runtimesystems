-- Test the callgrind profiler for a simple Lua program.
-- Command line usage: "lua lua-callgrind.lua <lua-script-name>" followed by "qcachegrind lua-callgrind.txt".
-- Make sure qcachegrind is installed on your system.

function loop()
  for i=1,10 do
    for j = 1,10 do
      local k = i + j
    end
  end
  return
end

loop()
