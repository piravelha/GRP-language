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
      if r:find("%s") and not r:sub(1, 1) == "[" and not r:sub(-1, -1) == "]" then
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

local function _flatten(...)
  local new = {}
  for _, o in pairs({...}) do
    if type(o) == "table" then
      for _, o2 in pairs(o) do
        table.insert(new, o2)
      end
    else
      table.insert(new, o)
    end
  end
  return new
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

function _invoke(args)
  if not args or #args == 0 then
    return
  end
  if #args == 1 then
    return args[1]()
  end
  local head = args[1]
  table.remove(args, 1)
  head(args)
end



function Sqrt()
  a = _stack:pop()
  _stack:push(math.sqrt(a))
end


function RandInt()
  a = _stack:pop()
  b = _stack:pop()
  math.randomseed(os.time() + os.clock())
  _stack:push(math.random(b, a))
end

function Random()
  math.randomseed(os.time() + os.clock())
  _stack:push(math.random())
end

function Iota()
local _symb_2_1 = _stack:pop()
L = function()
_stack:push(_symb_2_1)
end
L()
_stack:push(0)
-- <= --
a = _stack:pop()
b = _stack:pop()
_stack:push(b <= a and 1 or 0)
if _stack:pop() ~= 0 then
_stack:push(0)
temp = {}
temp[1] = _stack:pop()
_stack:push(_clone(temp))
else
L()
temp = {}
temp[1] = _stack:pop()
_stack:push(_clone(temp))
L()
_stack:push(1)
-- - --
a = _stack:pop()
b = _stack:pop()
_stack:push(b - a)
local _symb_3_1 = _stack:pop()
L = function()
_stack:push(_symb_3_1)
end
L()
Iota()
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
end
end
function Range()
local _symb_5_4 = _stack:pop()
Max = function()
_stack:push(_symb_5_4)
end
local _symb_6_4 = _stack:pop()
Min = function()
_stack:push(_symb_6_4)
end
temp = {}
_stack:push(_clone(temp))
local _symb_7_4 = _stack:pop()
Acc = function()
_stack:push(_symb_7_4)
end
while true do
Min()
Max()
-- < --
a = _stack:pop()
b = _stack:pop()
_stack:push(b < a and 1 or 0)
if _stack:pop() == 0 then
break
end
Acc()
Min()
_stack:push(1)
-- + --
a = _stack:pop()
b = _stack:pop()
_stack:push(b + a)
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _symb_8_4 = _stack:pop()
Min = function()
_stack:push(_symb_8_4)
end
temp = {}
temp[1] = _stack:pop()
_stack:push(_clone(temp))
-- append (++) --
a = _stack:pop()
b = _stack:pop()
c = _clone(b)
for x = 1, #a do
table.insert(c, a[x])
end
_stack:push(c)
local _symb_9_4 = _stack:pop()
Acc = function()
_stack:push(_symb_9_4)
end
end
Acc()
end
function Repeat()
local _symb_11_1 = _stack:pop()
N = function()
_stack:push(_symb_11_1)
end
local _symb_12_1 = _stack:pop()
X = function()
_stack:push(_symb_12_1)
end
temp = {}
_stack:push(_clone(temp))
local _symb_13_1 = _stack:pop()
Acc = function()
_stack:push(_symb_13_1)
end
while true do
N()
_stack:push(1)
-- > --
a = _stack:pop()
b = _stack:pop()
_stack:push(b > a and 1 or 0)
if _stack:pop() == 0 then
break
end
Acc()
X()
temp = {}
temp[1] = _stack:pop()
_stack:push(_clone(temp))
-- append (++) --
a = _stack:pop()
b = _stack:pop()
c = _clone(b)
for x = 1, #a do
table.insert(c, a[x])
end
_stack:push(c)
local _symb_14_1 = _stack:pop()
Acc = function()
_stack:push(_symb_14_1)
end
N()
_stack:push(1)
-- - --
a = _stack:pop()
b = _stack:pop()
_stack:push(b - a)
local _symb_15_1 = _stack:pop()
N = function()
_stack:push(_symb_15_1)
end
end
Acc()
end
function Prime()
local _symb_17_1 = _stack:pop()
N = function()
_stack:push(_symb_17_1)
end
N()
_stack:push(2)
-- < --
a = _stack:pop()
b = _stack:pop()
_stack:push(b < a and 1 or 0)
if _stack:pop() ~= 0 then
_stack:push(0)
else
_stack:push(2)
_stack:push(3)
temp = {}
temp[2] = _stack:pop()
temp[1] = _stack:pop()
_stack:push(_clone(temp))
N()
-- find (<#) --
a = _stack:pop()
b = _stack:pop()
c = 0
for i, x in pairs(b) do
if x == a then
c = i
break
end
end
_stack:push(c)
if _stack:pop() ~= 0 then
_stack:push(1)
else
_stack:push(2)
N()
Sqrt()
Range()
_var_18 = {}
_var_19 = _stack:pop()
for _var_20, _var_21 in pairs(_var_19) do
_stack:push(_var_21)
_invoke(_flatten({function()
N()
-- flip (<|>) --
a = _stack:pop()
b = _stack:pop()
_stack:push(a)
_stack:push(b)
-- % --
a = _stack:pop()
b = _stack:pop()
_stack:push(b % a)

end}))
table.insert(_var_18, _stack:pop())
end
_stack:push(_clone(_var_18))
_var_23 = _stack:pop()
_var_22 = nil
for _, _var_24 in pairs(_var_23) do
if not _var_22 then
_var_22 = _var_24
else
_stack:push(_var_22)
_stack:push(_var_24)
_invoke(_flatten({function()
-- and (&) --
a = _stack:pop()
b = _stack:pop()
_stack:push(a ~= 0 and b or 0)

end}))
_var_22 = _stack:pop()
end
end
_stack:push(_var_22)
end
end
end
function MeuPenisCm()
_stack:push(0)
_stack:push(6942)
Range()
_var_27 = _stack:pop()
_var_26 = nil
for _, _var_28 in pairs(_var_27) do
if not _var_26 then
_var_26 = _var_28
else
_stack:push(_var_26)
_stack:push(_var_28)
_invoke(_flatten({function()
-- + --
a = _stack:pop()
b = _stack:pop()
_stack:push(b + a)

end}))
_var_26 = _stack:pop()
end
end
_stack:push(_var_26)
end
MeuPenisCm()
a = _stack:pop()
_stack:push(_split(_repr(a)))
_stack:push({_str = true, "c", "m"})
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
