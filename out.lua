local function _repr(obj)
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
  for i, elem in pairs(obj) do
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
    if _eq(x, ys[i]) == 0 then
      return 0
    end
  end

  for i, y in pairs(ys) do
    if _eq(y, xs[i]) == 0 then
      return 0
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

function Map(F)
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _symb_1 = _stack:pop()
local L = function()
_stack:push(_symb_1)
end
local _match_2 = _stack:pop()
temp = {}
_stack:push(_clone(temp))
if _eq(_match_2, _stack:pop()) ~= 0 then
temp = {}
_stack:push(_clone(temp))
_match_2 = _stack:pop()
else
L()
-- head (/.) --
a = _stack:pop()
_stack:push(a[1])
_invoke(F)
L()
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
_match_2 = _stack:pop()
end
_stack:push(_match_2)
end
_stack:push(0)
-- dup (.) --
a = _stack:pop()
_stack:push(a)
_stack:push(a)
local _match_3 = _stack:pop()
_stack:push(0)
if _eq(_match_3, _stack:pop()) ~= 0 then
-- pop (,) --
_stack:pop()
_stack:push(0)
_match_3 = _stack:pop()
else
_stack:push(2)
-- + --
a = _stack:pop()
b = _stack:pop()
_stack:push(b + a)
_match_3 = _stack:pop()
end
_stack:push(_match_3)
-- dump (|<) --
a = _stack:pop()
print(_repr(a))
-- dump (|<) --
a = _stack:pop()
print(_repr(a))
