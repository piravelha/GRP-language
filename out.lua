local function _repr(obj)
  if type(obj) ~= "table" then
    return tostring(obj)
  end
  if obj._str then
    local allChars = true
    for i, x in pairs(obj) do
      if type(i) == "number" then
        if type(x) ~= "string" or #x ~= 1 then
          allChars = false
        end
      end
    end
    if allChars then
      local str = ""
      for i, x in pairs(obj) do
        if type(i) == "number" then
          str = str .. x
        end
      end
      return str
    end
  end
  local str = "["
  for i, elem in pairs(obj) do
    if type(i) == "number" then
      local r = _repr(elem)
      if r:find("%s") then
        str = str .. "(" .. r .. ")"
      else
        str = str .. _repr(elem)
      end
      if i < #obj then
        str = str .. " "
      end
    end
  end

  return str .. "]"
end

local function _clone(tbl)
  local new = {}
  for i, v in pairs(tbl) do
    new[i] = v
  end
  return new
end

local function _split(str)
  local tbl = {_str = true}
  for i= 1, #str do
    table.insert(tbl, str:sub(i, i))
  end
  return tbl
end

local _stack = {
  values = {},
  push = function(self, x)
    table.insert(self.values, 1, x)
  end,
  pop = function(self)
    local popped = table.remove(self.values, 1)
    return popped
  end,
  print = function(self)
    print(_repr(self.values))
  end
}


function Solution()
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
_var_1 = {}
_var_2 = _stack:pop()
for _, _var_3 in pairs(_var_2) do
_stack:push(_var_3)
_stack:push(0)
-- > --
a = _stack:pop()b = _stack:pop()_stack:push(b > a and 1 or 0)if _stack:pop() ~= 0 then
table.insert(_var_1, _var_3)
end
end
_stack:push(_var_1)
a = _stack:pop()
_stack:push(#a)
-- flip (<|>) --
a = _stack:pop()
b = _stack:pop()
_stack:push(a)
_stack:push(b)
_var_4 = {}
_var_5 = _stack:pop()
for _, _var_6 in pairs(_var_5) do
_stack:push(_var_6)
_stack:push(0)
-- < --
a = _stack:pop()b = _stack:pop()_stack:push(b < a and 1 or 0)if _stack:pop() ~= 0 then
table.insert(_var_4, _var_6)
end
end
_stack:push(_var_4)
a = _stack:pop()
_stack:push(#a)
-- max (|+|) --
a = _stack:pop()
b = _stack:pop()
if a > b then
_stack:push(a)
else
_stack:push(b)
end
end
_stack:push(0)
_stack:push(1)
a = _stack:pop()
_stack:push(-a)
_stack:push(1)
_stack:push(2)
_stack:push(3)
a = _stack:pop()
_stack:push(-a)
_stack:push(1)
_stack:push(4)
_stack:push(4)
a = _stack:pop()
_stack:push(-a)
_stack:push(1)
a = _stack:pop()
_stack:push(-a)
_stack:push(7)
a = _stack:pop()
_stack:push(-a)
temp = {}
temp[1] = _stack:pop()
temp[2] = _stack:pop()
temp[3] = _stack:pop()
temp[4] = _stack:pop()
temp[5] = _stack:pop()
temp[6] = _stack:pop()
temp[7] = _stack:pop()
temp[8] = _stack:pop()
temp[9] = _stack:pop()
temp[10] = _stack:pop()
_stack:push(_clone(temp))
Solution()
a = _stack:pop()
_stack:push(_split(_repr(a)))
_stack:push({_str = true, ">", ">", ">", " "})
-- flip (<|>) --
a = _stack:pop()
b = _stack:pop()
_stack:push(a)
_stack:push(b)
-- append (++) --
a = _stack:pop()
b = _stack:pop()
c = _clone(b)
for x = 1, #a do
table.insert(c, a[x])
end
_stack:push(c)
-- dump (|<) --
a = _stack:pop()
print(_repr(a))
