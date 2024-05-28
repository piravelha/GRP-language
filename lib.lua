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


