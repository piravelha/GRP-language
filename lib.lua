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


