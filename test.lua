local ffi = require("ffi")

local function add(x, y)
  return x + y
end

local sum = 0
for i = 1, 1000000 do
  sum = add(sum, i)
  sum = add(sum, i) - add(sum, i - 1)
  sum = add(sum * 2, i / 2)
end

print(sum)
