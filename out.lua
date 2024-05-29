local function _matrix_repr(obj)
  if type(obj) ~= "table" then
    return tostring(obj)
  end
  if getmetatable(obj) and getmetatable(obj).__tostring then
      return tostring(obj)
  end
  local str = "["
  for i, elem in pairs(obj) do
    if type(i) == "number" then
      local r = _repr(elem)
      str = str .. r
      if i < #obj then
        str = str .. "\n "
      end
    end
  end
  return str .. "]"
end

function _repr(obj)
  if type(obj) ~= "table" then
    return tostring(obj)
  end
  if getmetatable(obj) and getmetatable(obj).__tostring then
    return tostring(obj)
  end
  if #obj > 0 then
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
  local allTables = true
  for i, elem in pairs(obj) do
    if type(elem) ~= "table" then
      allTables = false
    end
    if type(i) == "number" then
      local r = _repr(elem)
      if r:find("%s") and r:sub(1, 1) ~= "[" and r:sub(-1, -1) ~= "]" then
        str = str .. "(" .. r .. ")"
      else
        str = str .. r
      end
      if i < #obj then
        str = str .. " "
      end
    end
  end

  return str .. "]"
end

local function _eq(xs, ys)
  if type(xs) ~= "table" or type(ys) ~= "table" then
    return xs == ys and 1 or 0
  end

  for i, x in pairs(xs) do
    if type(i) == "number" then
      if _eq(x, ys[i]) == 0 then
        return 0
      end
    end
  end

  for i, y in pairs(ys) do
    if type(i) == "number" then
      if _eq(y, xs[i]) == 0 then
        return 0
      end
    end
  end
   
  if #xs ~= #ys then
    return 0
  end

  return 1
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
  args = args or {}
  if not args or #args == 0 then
    return
  end
  if #args == 1 then
    return args[1]()
  end
  local head = args[1]
  local args = _clone(args)
  table.remove(args, 1)
  head(args)
end


function _data()
  local name = _stack:pop()
  local args = _stack:pop()
  _stack:push(setmetatable({
    _type = name,
    _args = args,
  }, {
    __tostring = function()
      local str = _repr(name)
      for _, a in pairs(args) do
        str = _repr(a) .. " " .. str
      end
      return str
    end
  }))
end


function __HASH(X)
  X = X or {}
  _stack:push(#X)
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

function Not()
local _symb_2_1 = _stack:pop()
local B = function()
_stack:push(_symb_2_1)
end
local _match_3 = _stack:pop()
_stack:push(_match_3)
B()
if _stack:pop() ~= 0 then
_stack:push(0)
_match_3 = _stack:pop()
else
_stack:push(1)
_match_3 = _stack:pop()
end
_stack:push(_match_3)
end
function _33()
Not()
end
function Max()
local _symb_6_5 = _stack:pop()
local N = function()
_stack:push(_symb_6_5)
end
local _symb_7_5 = _stack:pop()
local M = function()
_stack:push(_symb_7_5)
end
N()
local _match_8 = _stack:pop()
_stack:push(_match_8)
M()
-- < --
a = _stack:pop()
b = _stack:pop()
_stack:push(b < a and 1 or 0)
if _stack:pop() ~= 0 then
M()
_match_8 = _stack:pop()
else
N()
_match_8 = _stack:pop()
end
_stack:push(_match_8)
end
function _61_43_61()
Max()
end
function Min()
local _symb_11_1 = _stack:pop()
local N = function()
_stack:push(_symb_11_1)
end
local _symb_12_1 = _stack:pop()
local M = function()
_stack:push(_symb_12_1)
end
N()
local _match_13 = _stack:pop()
_stack:push(_match_13)
M()
-- > --
a = _stack:pop()
b = _stack:pop()
_stack:push(b > a and 1 or 0)
if _stack:pop() ~= 0 then
M()
_match_13 = _stack:pop()
else
N()
_match_13 = _stack:pop()
end
_stack:push(_match_13)
end
function _61_45_61()
Min()
end
function Range()
local _symb_16_1 = _stack:pop()
local Max = function()
_stack:push(_symb_16_1)
end
local _symb_17_1 = _stack:pop()
local Min = function()
_stack:push(_symb_17_1)
end
temp = {}
_stack:push(_clone(temp))
local _symb_18_1 = _stack:pop()
local Acc = function()
_stack:push(_symb_18_1)
end
while true do
Min()
Max()
-- <= --
a = _stack:pop()
b = _stack:pop()
_stack:push(b <= a and 1 or 0)
if _stack:pop() == 0 then
break
end
Acc()
Min()
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
_symb_19_1 = _stack:pop()
Acc = function()
_stack:push(_symb_19_1)
end
Min()
_stack:push(1)
-- + --
a = _stack:pop()
b = _stack:pop()
_stack:push(b + a)
_symb_20_1 = _stack:pop()
Min = function()
_stack:push(_symb_20_1)
end
end
Acc()
end
function Indices()
local _symb_22_2 = _stack:pop()
local Xs = function()
_stack:push(_symb_22_2)
end
_stack:push(1)
local _symb_23_2 = _stack:pop()
local I = function()
_stack:push(_symb_23_2)
end
temp = {}
_stack:push(_clone(temp))
local _symb_24_2 = _stack:pop()
local Acc = function()
_stack:push(_symb_24_2)
end
while true do
I()
Xs()
-- length (#) --
a = _stack:pop()
_stack:push(#a)
-- <= --
a = _stack:pop()
b = _stack:pop()
_stack:push(b <= a and 1 or 0)
if _stack:pop() == 0 then
break
end
Acc()
I()
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
_symb_25_2 = _stack:pop()
Acc = function()
_stack:push(_symb_25_2)
end
I()
_stack:push(1)
-- + --
a = _stack:pop()
b = _stack:pop()
_stack:push(b + a)
_symb_26_2 = _stack:pop()
I = function()
_stack:push(_symb_26_2)
end
end
Acc()
end
function Reverse()
local _symb_28_2 = _stack:pop()
local List = function()
_stack:push(_symb_28_2)
end
List()
-- length (#) --
a = _stack:pop()
_stack:push(#a)
local _symb_29_2 = _stack:pop()
local I = function()
_stack:push(_symb_29_2)
end
temp = {}
_stack:push(_clone(temp))
local _symb_30_2 = _stack:pop()
local Acc = function()
_stack:push(_symb_30_2)
end
while true do
Acc()
-- length (#) --
a = _stack:pop()
_stack:push(#a)
List()
-- length (#) --
a = _stack:pop()
_stack:push(#a)
-- < --
a = _stack:pop()
b = _stack:pop()
_stack:push(b < a and 1 or 0)
if _stack:pop() == 0 then
break
end
List()
I()
-- index (!!) --
a = _stack:pop()
b = _stack:pop()
_stack:push(b[a])
_124_95_124()
Acc()
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
_symb_31_2 = _stack:pop()
Acc = function()
_stack:push(_symb_31_2)
end
I()
_stack:push(1)
-- - --
a = _stack:pop()
b = _stack:pop()
_stack:push(b - a)
_symb_32_2 = _stack:pop()
I = function()
_stack:push(_symb_32_2)
end
end
Acc()
end
function _124_95_124()
local _symb_34_3 = _stack:pop()
local E = function()
_stack:push(_symb_34_3)
end
E()
temp = {}
temp[1] = _stack:pop()
_stack:push(_clone(temp))
end
function _60_95_62()
Reverse()
end
function Map(F)
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _match_36 = _stack:pop()
_stack:push(_match_36)
temp = {}
_stack:push(_clone(temp))
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))
if _stack:pop() ~= 0 then
-- pop (,) --
_stack:pop()
temp = {}
_stack:push(_clone(temp))
_match_36 = _stack:pop()
else
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
_invoke(F)
-- flip (<|>) --
a = _stack:pop()
b = _stack:pop()
_stack:push(a)
_stack:push(b)
-- tail (/@) --
a = _stack:pop()
b = {}
for i = 2, #a do
table.insert(b, a[i])
end
_stack:push(b)
_invoke(_flatten({Map}, F))
-- cons (:>) --
a = _stack:pop()
b = _stack:pop()
c = _clone(a)
table.insert(c, 1, b)
_stack:push(c)
_match_36 = _stack:pop()
end
_stack:push(_match_36)
end
function FlatMap(F)
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _match_37 = _stack:pop()
_stack:push(_match_37)
temp = {}
_stack:push(_clone(temp))
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))
if _stack:pop() ~= 0 then
-- pop (,) --
_stack:pop()
temp = {}
_stack:push(_clone(temp))
_match_37 = _stack:pop()
else
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
_invoke(F)
-- flip (<|>) --
a = _stack:pop()
b = _stack:pop()
_stack:push(a)
_stack:push(b)
-- tail (/@) --
a = _stack:pop()
b = {}
for i = 2, #a do
table.insert(b, a[i])
end
_stack:push(b)
_invoke(_flatten({Map}, F))
-- append (++) --
a = _stack:pop()
b = _stack:pop()
c = _clone(b)
for x = 1, #a do
table.insert(c, a[x])
end
_stack:push(c)
_match_37 = _stack:pop()
end
_stack:push(_match_37)
end
function ZipWith(F)
local _symb_38 = _stack:pop()
local Ys = function()
_stack:push(_symb_38)
end
local _symb_39 = _stack:pop()
local Xs = function()
_stack:push(_symb_39)
end
Ys()
local _match_40 = _stack:pop()
_stack:push(_match_40)
temp = {}
_stack:push(_clone(temp))
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))
if _stack:pop() ~= 0 then
temp = {}
_stack:push(_clone(temp))
_match_40 = _stack:pop()
else
Xs()
local _match_41 = _stack:pop()
_stack:push(_match_41)
temp = {}
_stack:push(_clone(temp))
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))
if _stack:pop() ~= 0 then
temp = {}
_stack:push(_clone(temp))
_match_41 = _stack:pop()
else
Xs()
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
Ys()
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
_invoke(F)
Xs()
-- tail (/@) --
a = _stack:pop()
b = {}
for i = 2, #a do
table.insert(b, a[i])
end
_stack:push(b)
Ys()
-- tail (/@) --
a = _stack:pop()
b = {}
for i = 2, #a do
table.insert(b, a[i])
end
_stack:push(b)
_invoke(_flatten({ZipWith}, F))
-- cons (:>) --
a = _stack:pop()
b = _stack:pop()
c = _clone(a)
table.insert(c, 1, b)
_stack:push(c)
_match_41 = _stack:pop()
end
_stack:push(_match_41)
_match_40 = _stack:pop()
end
_stack:push(_match_40)
end
function MinRowLength()
_invoke(_flatten({Map}, {function()
-- length (#) --
a = _stack:pop()
_stack:push(#a)

end}))
_var_44 = _stack:pop()
_var_43 = nil
for _, _var_45 in pairs(_var_44) do
if not _var_43 then
_var_43 = _var_45
else
_stack:push(_var_43)
_stack:push(_var_45)
_invoke(_flatten({function()
Min()

end}))
_var_43 = _stack:pop()
end
end
_stack:push(_var_43)
end
function Transpose()
local _symb_47_4 = _stack:pop()
local Matrix = function()
_stack:push(_symb_47_4)
end
_stack:push(1)
Matrix()
MinRowLength()
Range()
_invoke(_flatten({Map}, {function()
local _symb_48 = _stack:pop()
local I = function()
_stack:push(_symb_48)
end
Matrix()
I()
-- index (!!) --
a = _stack:pop()
b = _stack:pop()
_stack:push(b[a])
local _symb_49 = _stack:pop()
local Row = function()
_stack:push(_symb_49)
end
Matrix()
-- indices (%^) --
Indices()
_invoke(_flatten({Map}, {function()
local _symb_50 = _stack:pop()
local J = function()
_stack:push(_symb_50)
end
Matrix()
J()
-- index (!!) --
a = _stack:pop()
b = _stack:pop()
_stack:push(b[a])
I()
-- index (!!) --
a = _stack:pop()
b = _stack:pop()
_stack:push(b[a])

end}))

end}))
end
function TakeWhile(F)
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _symb_51 = _stack:pop()
local Xs = function()
_stack:push(_symb_51)
end
local _match_52 = _stack:pop()
_stack:push(_match_52)
temp = {}
_stack:push(_clone(temp))
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))
if _stack:pop() ~= 0 then
temp = {}
_stack:push(_clone(temp))
_match_52 = _stack:pop()
else
_stack:push(_match_52)
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
_invoke(F)
Not()
if _stack:pop() ~= 0 then
temp = {}
_stack:push(_clone(temp))
_match_52 = _stack:pop()
else
Xs()
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
Xs()
-- tail (/@) --
a = _stack:pop()
b = {}
for i = 2, #a do
table.insert(b, a[i])
end
_stack:push(b)
_invoke(_flatten({TakeWhile}, F))
-- cons (:>) --
a = _stack:pop()
b = _stack:pop()
c = _clone(a)
table.insert(c, 1, b)
_stack:push(c)
_match_52 = _stack:pop()
end
end
_stack:push(_match_52)
end
function LongestPrefix()
local _symb_54_5 = _stack:pop()
local Strs = function()
_stack:push(_symb_54_5)
end
Strs()
Transpose()
_invoke(_flatten({Map}, {function()
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _symb_55 = _stack:pop()
local Str = function()
_stack:push(_symb_55)
end
_invoke(_flatten({TakeWhile}, {function()
Str()
_stack:push(1)
-- index (!!) --
a = _stack:pop()
b = _stack:pop()
_stack:push(b[a])
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))

end}))

end}))
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _symb_56_5 = _stack:pop()
local Prefixes = function()
_stack:push(_symb_56_5)
end
_invoke(_flatten({TakeWhile}, {function()
-- length (#) --
a = _stack:pop()
_stack:push(#a)
Prefixes()
_stack:push(1)
-- index (!!) --
a = _stack:pop()
b = _stack:pop()
_stack:push(b[a])
-- length (#) --
a = _stack:pop()
_stack:push(#a)
-- equals (=) --
a = _stack:pop()
b = _stack:pop()
_stack:push(_eq(a, b))

end}))
_invoke(_flatten({Map}, {function()
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])

end}))
end
_stack:push({_str = true, "f", "l", "o", "w", "e", "r"})
_stack:push({_str = true, "f", "l", "o", "w"})
_stack:push({_str = true, "f", "l", "o", "w", "h", "t"})
temp = {}
temp[3] = _stack:pop()
temp[2] = _stack:pop()
temp[1] = _stack:pop()
_stack:push(_clone(temp))
LongestPrefix()
-- dump (|<) --
a = _stack:pop()
print(_repr(a))
