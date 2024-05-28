from parser import parser
from lark import Tree, Token

import re
import subprocess

debug = False


def compile_number(code, value):
  if debug:
    code += "print(\"(DEBUG) Pushing %s\")" % value
  code += "_stack:push(%s)\n" % value
  if debug:
    code += "_stack:print()\n"
  return code

def compile_combinator(code, operators):
  for op in operators:
    code = compile_operator(code, op)
  return code

def compile_operator(code, value):
  if debug:
    code += "print(\"(DEBUG) Performing '%s'\")" % value

  if value in ["+", "-", "*", "/"]:
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b %s a)\n" % value
  elif value == "-^":
    code += "a = _stack:pop()\n"
    code += "_stack:push(-a)\n"
  elif value == "=":
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b == a and 1 or 0)\n"
  elif value in ["<", ">", "<=", ">="]:
    code += "a = _stack:pop()"
    code += "b = _stack:pop()"
    code += "_stack:push(b %s a and 1 or 0)" % value
  elif value == "|<":
    code += "a = _stack:pop()\n"
    code += "print(a)\n"
  elif value == ".":
    code += "a = _stack:pop()\n"
    code += "_stack:push(a)\n"
    code += "_stack:push(a)\n"
  elif value == "..":
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(b)\n"
    code += "_stack:push(a)\n"
    code += "_stack:push(b)\n"
    code += "_stack:push(a)\n"
  elif value == "<|>":
    code += "a = _stack:pop()\n"
    code += "b = _stack:pop()\n"
    code += "_stack:push(a)\n"
    code += "_stack:push(b)\n"
  else:
    assert False, "Invalid operator: %s" % value
  if debug:
    code += "_stack:print()\n"
  return code

def compile_name(code, value):
  if debug:
    code += "print(\"(DEBUG) Calling '%s'\")\n" % value
  code += "%s()\n" % value
  if debug:
    code += "_stack:print()\n"
  return code

var_count_ = 0
def var_count():
  global var_count_
  var_count_ += 1
  return var_count_

def compile_symbol(code, value):
  if debug:
    code += "print(\"(DEBUG) Saving to '%s'\t\")\n" % value
  var = "_symb_%d" % var_count()
  code += "%s = _stack:pop()\n" % var
  code += "%s = function()\n" % value
  code += "_stack:push(%s)\n" % var
  code += "end\n"
  if debug:
    code += "_stack:print()\n"
  return code

def compile_declaration(code, name, *values):
  if debug:
    code += "print(\"(DEBUG) Declaring '%s'\")" % name
  code += "function %s()\n" % name
  for val in values:
    code = compile_tree(code, val)
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

def compile_while(code, cond, body):
  code += "while true do\n"
  code = compile_tree(code, cond)
  code += "if _stack:pop() == 0 then\n"
  code += "break\n"
  code += "end\n"
  code = compile_tree(code, body)
  code += "end\n"
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
  if tree.data == "symbol":
    return compile_symbol(code, *tree.children)
  if tree.data == "declaration":
    return compile_declaration(code, *tree.children)
  if tree.data == "expression":
    return compile_expression(code, tree.children)
  if tree.data == "program":
    return compile_program(code, tree.children)
  if tree.data == "paren":
    return compile_expression(code, tree.children)
  if tree.data == "combinator":
    return compile_combinator(code, tree.children)
  if tree.data == "if":
    return compile_if(code, *tree.children)
  if tree.data == "while":
    return compile_while(code, *tree.children)
  assert False, "Unimplemented: %s" % tree.data

def compile(code):
  code = re.sub(r";.+", "", code)
  tree = parser.parse(code)
  with open("lib.lua") as f:
    lib = f.read()
  result = compile_tree(lib, tree)
  with open("out.lua", "w") as f:
    f.write(result)
  subprocess.run(["luajit", "out.lua"])

with open("in.grp") as f:
  compile(f.read())
