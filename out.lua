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
    local str = "["
    for i, x in pairs(self.values) do
      str = str .. tostring(x)
      if i < #self.values then
        str = str .. " "
      end
    end
    print("(STACK)", str .. "]")
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
_stack:push(50)
Factorial()
a = _stack:pop()
print(a)
