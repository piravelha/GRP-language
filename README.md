# Welcome to GRP */grape/*

![image](https://github.com/piravelha/GRP-language/assets/140568241/1184021f-4437-4e6b-a063-40c3aa2856d4)

GRP is a simple, stack-based language currently written in Python, that transpiles to Lua.

Note that because GRP is a stack-based language, it is read left-to-right, so all functions are used in postfix form.

# Snippets

## Printing
To print an expression, you can either use `Print`, or you can type its operator form `|<`.
```grp
4 Print
7 |<
```
Output:
```sh
4
7
```


## Basic Operations
Remembering that all functions/operators are used in postfix form, it is sometimes harder
to understand an arithmetic expression, so you can use parenthesis to group parts of the
operation together to make it clearer, also, there is no operator precedence, every function
has the same left-precedence in GRP

```grp
1 2 + 4 * 3 / Print
1 (2+) (4*) (3/) Print
```
Output:
```sh
4
4
```

If that is still weird to you, just try thinking of a program as a list of instructions,
as a pipeline, and it should start making sense.
