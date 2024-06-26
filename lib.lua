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

