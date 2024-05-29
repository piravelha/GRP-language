from parser import parser
from lark import Tree, Token

import re
import subprocess

debug = False

var_count_ = 0
def var_count():
  global var_count_
  var_count_ += 1
  return var_count_

def new_var():
  return "_var_%d" % var_count()

def compile_number(code, value):
  code += "_stack:push(%s)\n" % value
  return code

def compile_string(code, value):
  code += "_stack:push({_str = true, %s})\n" % ", ".join(["\"%s\"" % c for c in value[1:-1]])
  return code

def compile_character(code, value):
  code += "_stack:push(%s)\n" % value
  return code


def compile_macro(code, name, splice, body):
  code += "function %s(%s)\n" % (name, splice.children[0])
  code = compile_tree(code, body)
  code += "end\n"
  return code

def compile_combinator(code, operators):
  if operators[0] == "$>":
    temp = new_var()
    code += "%s = {}\n" % temp
    a = new_var()
    i = new_var()
    x = new_var()
    code += "%s = _stack:pop()\n" % a
    code += "for %s, %s in pairs(%s) do\n" % (i, x, a)
    code += "_stack:push(%s)\n" % x
    code = compile_combinator(code, operators[1:])
    code += "table.insert(%s, _stack:pop())\n" % (temp)
    code += "end\n"
    code += "_stack:push(_clone(%s))\n" % temp
  elif operators[0] == "$|>":
    temp = new_var()
    code += "%s = {}\n" % temp
    a = new_var()
    i = new_var()
    x = new_var()
    x2 = new_var()
    code += "%s = _stack:pop()\n" % a
    code += "for %s, %s in pairs(%s) do\n" % (i, x, a)
    code += "_stack:push(%s)\n" % x
    code = compile_combinator(code, operators[1:])
    code += "for _, %s in pairs(_stack:pop()) do\n" % (x2)
    code += "table.insert(%s, %s)\n" % (temp, x2)
    code += "end\n"
    code += "end\n"
    code += "_stack:push(_clone(%s))\n" % temp
  elif operators[0] == "<:*>":
    temp = new_var()
    code += "%s = {}\n" % temp
    a = new_var()
    b = new_var()
    i = new_var()
    code += "%s = _stack:pop()\n" % a
    code += "%s = _stack:pop()\n" % b
    code += "for %s, _ in pairs(%s) do\n" % (i, b)
    code += "if %s[%s] == nil then break end\n" % (a, i)
    code += "_stack:push(%s[%s])\n" % (b, i)
    code += "_stack:push(%s[%s])\n" % (a, i)
    code = compile_combinator(code, operators[1:])
    code += "%s[%s] = _stack:pop()\n" % (temp, i)
    code += "end\n"
    code += "_stack:push(%s)\n" % temp
  elif operators[0] == "#>":
    temp = new_var()
    code += "%s = 0\n" % temp
    a = new_var()
    x = new_var()
    i = new_var()
    code += "%s = _stack:pop()\n" % a
    code += "for %s, %s in pairs(%s) do\n" % (i, x, a)
    code += "_stack:push(%s)\n" % x
    code = compile_combinator(code, operators[1:])
    code += "if _stack:pop() ~= 0 then\n"
    code += "%s = %s\n" % (temp, i)
    code += "break\n"
    code += "end\n"
    code += "end\n"
    code += "_stack:push(%s)\n" % temp
  elif operators[0] == "&>":
    temp = new_var()
    code += "%s = {}\n" % temp
    a = new_var()
    x = new_var()
    code += "%s = _stack:pop()\n" % a
    code += "for _, %s in pairs(%s) do\n" % (x, a)
    code += "_stack:push(%s)\n" % x
    code = compile_combinator(code, operators[1:])
    code += "if _stack:pop() ~= 0 then\n"
    code += "table.insert(%s, %s)\n" % (temp, x)
    code += "end\n"
    code += "end\n"
    code += "_stack:push(%s)\n" % temp

  elif operators[0] == "<>":
    temp = new_var()
    a = new_var()
    x = new_var()
    code += "%s = _stack:pop()\n" % a
    code += "%s = nil\n" % temp
    code += "for _, %s in pairs(%s) do\n" % (x, a)
    code += "if not %s then\n" % temp
    code += "%s = %s\n" % (temp, x)
    code += "else\n"
    code += "_stack:push(%s)\n" % temp
    code += "_stack:push(%s)\n" % x
    code = compile_combinator(code, operators[1:])
    code += "%s = _stack:pop()\n" % temp
    code += "end\n"
    code += "end\n"
    code += "_stack:push(%s)\n" % temp
  elif operators[0] == "%#":
    code = compile_combinator(
      code,
      [Token("NAME", "__HASH"),
      *operators[1:]]
    )
  else:
    ops = "_flatten("
    for i, o in enumerate(operators):
      if isinstance(o, Tree) and o.data.endswith("_splice"):
        if o.data == "id_splice":
          ops += o.children[0]
        if o.data == "head_splice":
          ops += "%s[1]" % o.children[0]
        if o.data == "tail_splice":
          ops += "(function()\n"
          ops += "local tail = _clone(%s)\n" % o.children[0]
          ops += "table.remove(tail, 1)\n"
          ops += "return tail\n"
          ops += "end)()"
        if i < len(operators):
          ops += ", "
      else:
        if isinstance(o, Token) and o.type == "NAME":
          ops += "{" + o + "}"
        else:
          o = compile_tree("", o)
          ops += "{function()\n%s\nend}" % o
        if i < len(operators):
          ops += ", "
    if ops.endswith(", "):
      ops = ops[:-2]
    ops = ops + ")"
    if isinstance(operators[0], Tree) and operators[0].data in ["id_splice", "head_splice", "tail_splice"]:
      code += "_invoke(%s)\n" % operators[0].children[0]
    else:
      code += "_invoke(%s)\n" % (ops)
  return code

def compile_splice(code, value):
  code += "_stack:push(%s or {})\n" % value
  return code

def compile_operator(code, value):
  if value in ["+", "-", "*", "/", "^", "%"]:
    code += "-- %s --\n" % value
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b %s a)\n" % value
  elif value == "^-":
    code += "-- unary minus (^-) --\n"
    code += "a = _stack:pop()\n"
    code += "_stack:push(-a)\n"
  elif value == "#":
    code += "-- length (#) --\n"
    code += "a = _stack:pop()\n"
    code += "_stack:push(#a)\n"
  elif value == "=":
    code += "-- equals (=) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(_eq(a, b))\n"
  elif value == "/=":
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(not _eq(a, b))\n"
  elif value in ["<", ">", "<=", ">="]:
    code += "-- %s --\n" % value
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b %s a and 1 or 0)\n" % value
  elif value == "|<":
    code += "-- dump (|<) --\n"
    code += "a = _stack:pop()\n"
    code += "print(_repr(a))\n"
  elif value == ".":
    code += "-- dup (.) --\n"
    code += "a = _stack:pop()\n"
    code += "_stack:push(a)\n"
    code += "_stack:push(a)\n"
  elif value == ";":
    code += "-- dup last (;) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()"
    code += "_stack:push(b)\n" 
    code += "table.insert(_stack.values, a, b)\n"
  elif value == ",":
    code += "-- pop (,) --\n"
    code += "_stack:pop()\n"
  elif value == "..":
    code += "-- double dup (..) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b)\n"
    code += "_stack:push(a)\n"
    code += "_stack:push(b)\n"
    code += "_stack:push(a)\n"
  elif value == "<|>":
    code += "-- flip (<|>) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(a)\n"
    code += "_stack:push(b)\n"
  elif value == "++":
    code += "-- append (++) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "c = _clone(b)\n"
    code += "for x = 1, #a do\n"
    code += "table.insert(c, a[x])\n"
    code += "end\n"
    code += "_stack:push(c)\n"
  elif value == "|+|":
    code += "-- max (|+|) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "if a > b then\n"
    code += "_stack:push(a)\n"
    code += "else\n"
    code += "_stack:push(b)\n"
    code += "end\n"
  elif value == "?":
    code += "a = _stack:pop()\n"
    code += "_stack:push(_split(_repr(a)))\n"
  elif value == "???":
    code += "-- debug stack (???) --\n"
    code += "_stack:print()\n"
  elif value == "!!":
    code += "-- index (!!) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b[a])\n"
  elif value == "/.":
    code += "-- head (/.) --\n"
    code += "a = _stack:pop()\n"
    code += "_stack:push(a[1])\n"
  elif value == "./":
    code += "-- last (./) --\n"
    code += "a = _stack:pop()\n"
    code += "_stack:push(a[#a])\n"
  elif value == "/@":
    code += "-- tail (/@) --\n"
    code += "a = _stack:pop()\n"
    code += "b = {}\n"
    code += "for i = 2, #a do\n"
    code += "table.insert(b, a[i])\n"
    code += "end\n"
    code += "_stack:push(b)\n"
  elif value == "/:":
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b._args[a])\n"
  elif value == "<#":
    code += "-- find (<#) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "c = 0\n"
    code += "for i, x in pairs(b) do\n"
    code += "if _eq(a, x) then\n"
    code += "c = i\n"
    code += "break\n"
    code += "end\n"
    code += "end\n"
    code += "_stack:push(c)\n"
  elif value == "|=|":
    code += "-- box (|=|) --\n"
    code += "a = _stack:pop()\n"
    code += "_stack:push({a})\n"
  elif value == "&":
    code += "-- and (&) --\n"
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(a ~= 0 and b or 0)\n"
  elif value == "%^":
    code += "-- indices (%^) --\n"
    code += "a = _stack:pop()\n"
    code += "b = {}\n"
    code += "for i, x in pairs(a) do\n"
    code += "if x ~= 0 then\n"
    code += "table.insert(b, i)\n"
    code += "end\n"
    code += "end\n"
    code += "_stack:push(b)\n"
  elif value == "<:>":
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "c = {}\n"
    code += "for i, x in pairs(b) do\n"
    code += "if a[i] == nil then break end\n"
    code += "c[i] = {x, a[i]}\n"
    code += "end\n"
    code += "_stack:push(c)\n"
  else:
    assert False, "Invalid operator: %s" % value
  return code

def compile_name(code, value):
  path = value.split("/")
  final = "%s" % path[0]
  for p in path[1:]:
    final = "%s()[\"%s\"]" % (final, p)
  code += "%s()\n" % final
  return code

def compile_array(code, values):
  for val in values:
    code = compile_tree(code, val)
  code += "temp = {}\n"
  for i in range(len(values)):
    code += "temp[%d] = _stack:pop()\n" % (len(values) - i)
  code += "_stack:push(_clone(temp))\n"
  return code

def compile_symbol(code, value):
  marks = re.findall(r"&SYM_(\d+)&", code)
  mark = ""
  if marks:
    mark = "_%s" % marks[0][0]
  var = "_symb_%d%s" % (var_count(), mark)
  code += "local %s = _stack:pop()\n" % var
  code += "%s = function()\n" % value
  code += "_stack:push(%s)\n" % var
  code += "end\n"
  return code

def compile_declaration(code, name, *values):
  code += "function %s()\n" % name
  code = "&SYM_%d&" % var_count() + code
  for val in values:
    code = compile_tree(code, val)
  code += "end\n"
  sym_marks = re.findall(r"&SYM_\d+&", code)
  code = code.replace(sym_marks[0], "")
  return code

def compile_data(code, name, value):
  code += "function %s()\n" % name
  code = "&SYM_%d&" % var_count() + code
  code = compile_tree(code, value)
  code += "_stack:push(\"%s\")\n" % name
  code += "_data()\n"
  code += "end\n"
  sym_marks = re.findall(r"&SYM_\d+&", code)
  code = code.replace(sym_marks[0], "")
  return code



def compile_module(code, name, *decls):
  code += "function %s()\n" % name
  dec_names = []
  for dec in decls:
    code += "local "
    code = compile_tree(code, dec)
    dec = compile_tree("", dec)
    dec_names.append(dec.split("()\n")[0].split("function ")[1])
  code += "return {\n"
  for n in dec_names:
    code += "%s = %s,\n" % (n, n)
  code += "}\n"
  code += "end\n"
  return code

def compile_expression(code, atoms):
  for a in atoms:
    code = compile_tree(code, a)
  return code

def compile_if(code, true):
  code += "if _stack:pop() ~= 0 then\n"
  code = compile_tree(code, true)
  code += "end\n"
  return code

def compile_ifelse(code, true, false):
  code += "if _stack:pop() ~= 0 then\n"
  code = compile_tree(code, true)
  code += "else\n"
  code = compile_tree(code, false)
  code += "end\n"
  return code

def compile_while(code, cond, body):
  code += "while true do\n"
  code = compile_tree(code, cond)
  code += "if _stack:pop() == 0 then\n"
  code += "break\n"
  code += "end\n"
  code = compile_tree(code, body)
  code += "end\n"
  return code

def compile_eval(code, atoms):
  for a in atoms:
    code = compile_tree(code, a)
  return code

def compile_program(code, args):
  *decls, expr = args
  for dec in decls:
    code = compile_tree(code, dec)
  code = compile_tree(code, expr)
  return code

def compile_tree(code, tree):
  if isinstance(tree, Token):
    if tree.type == "NUMBER":
      return compile_number(code, tree.value)
    if tree.type == "OPERATOR":
      return compile_operator(code, tree.value)
    if tree.type == "NAME":
      return compile_name(code, tree.value)
    if tree.type == "STRING":
      return compile_string(code, tree.value)
    if tree.type == "CHARACTER":
      return compile_character(code, tree.value)
  if tree.data == "symbol":
    return compile_symbol(code, *tree.children)
  if tree.data == "array":
    return compile_array(code, tree.children)
  if tree.data == "declaration":
    return compile_declaration(code, *tree.children)
  if tree.data == "expression":
    return compile_expression(code, tree.children)
  if tree.data == "eval":
    return compile_eval(code, tree.children)
  if tree.data == "program":
    return compile_program(code, tree.children)
  if tree.data == "paren":
    return compile_expression(code, tree.children)
  if tree.data == "combinator":
    return compile_combinator(code, tree.children)
  if tree.data == "macro":
    return compile_macro(code, *tree.children)
  if tree.data == "id_splice":
    return compile_splice(code, *tree.children)
  if tree.data == "if":
    return compile_if(code, *tree.children)
  if tree.data == "ifelse":
    return compile_ifelse(code, *tree.children)
  if tree.data == "while":
    return compile_while(code, *tree.children)
  if tree.data == "module":
    return compile_module(code, *tree.children)
  if tree.data == "data":
    return compile_data(code, *tree.children)
  assert False, "Unimplemented: %s" % tree.data

def compile(code):
  code = re.sub(r";;.*", "", code, flags=re.MULTILINE)
  with open("lib.grp") as f:
    grplib = f.read()
  tree = parser.parse(grplib + code)
  with open("lib.lua") as f:
    lib = f.read()
  result = compile_tree(lib, tree)
  with open("out.lua", "w") as f:
    f.write(result)
  subprocess.run(["luajit", "out.lua"])

with open("in.grp") as f:
  compile(f.read())
