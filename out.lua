local function _repr(obj)
  if type(obj) ~= "table" then
    return tostring(obj)
  end
  local str = "["
  for i, elem in pairs(obj) do
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

  return str .. "]"
end

local function _clone(tbl)
  local new = {}
  for i, v in pairs(tbl) do
    new[i] = v
  end
  return new
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


function Factorial()
a = _stack:pop()
_stack:push(a)
_stack:push(a)
_symb_1 = _stack:pop()
X = function()
_stack:push(_symb_1)
end
while true do
X()
_stack:push(1)
a = _stack:pop()b = _stack:pop()_stack:push(b > a and 1 or 0)if _stack:pop() == 0 then
break
end
X()
_stack:push(1)
a = _stack:pop()
b = _stack:pop()
_stack:push(b - a)
a = _stack:pop()
_stack:push(a)
_stack:push(a)
_symb_2 = _stack:pop()
X = function()
_stack:push(_symb_2)
end
a = _stack:pop()
b = _stack:pop()
_stack:push(b * a)
end
end
_stack:push(1)
_stack:push(2)
temp = {}
temp[1] = _stack:pop()
temp[2] = _stack:pop()
_stack:push(_clone(temp))
_stack:push(3)
_stack:push(4)
temp = {}
temp[1] = _stack:pop()
temp[2] = _stack:pop()
_stack:push(_clone(temp))
temp = {}
temp[1] = _stack:pop()
temp[2] = _stack:pop()
_stack:push(_clone(temp))
_var_3 = {}
_var_4 = _stack:pop()
for _var_5, _var_6 in pairs(_var_4) do
_stack:push(_var_6)
_var_8 = _stack:pop()
_var_7 = nil
for _, _var_9 in pairs(_var_8) do
if not _var_7 then
_var_7 = _var_9
else
_stack:push(_var_7)
_stack:push(_var_9)
a = _stack:pop()
b = _stack:pop()
_stack:push(b + a)
_var_7 = _stack:pop()
end
end
_stack:push(_var_7)
_var_3[#_var_4 - _var_5 + 1] = _stack:pop()
end
_stack:push(_clone(_var_3))
a = _stack:pop()
print(_repr(a))
