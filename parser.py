from lark import Lark

with open("grammar.lark") as f:
  grammar = f.read()

parser = Lark(grammar)
