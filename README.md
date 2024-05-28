# Welcome to GRP */grape/*

GRP is a simple, stack-based language currently written in Python, that transpiles to Lua.

(This whole thing is currently a bit of a mess, since it is 100% written on my phone, at 2 in the morning, so please report bugs and any feedback you have!)

# Snippets

## Summing two numbers
<img src=https://github.com/piravelha/GRP-language/assets/140568241/e32d7564-8be1-4012-996b-754ca421ff49>

### Explanation
Since GRP is a stack-based language, the program is read like a sequence of instructions, from left, to right.

In this case, we have 4 instructions:
- **`1`**: Pushes *1* onto the stack.
- **`2`**: Pushes *2* onto the stack.
- **`+`**: Sums the two top elements of the stack, popping them, and pushes the result.
- **`|<`**: Pops the first element of the stack and prints it to the console.

So we expect the result of this program to be `3` (`print(1 + 2)`).
