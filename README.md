# Welcome to GRP */grape/*

GRP is a simple, stack-based language currently written in Python, that transpiles to Lua.

(This whole thing is currently a bit of a mess, since it is 100% written on my phone, at 2 in the morning, so please report bugs and any feedback you have!)

# Snippets

## Summing two numbers
![Screenshot_20240528-222520_Termux](https://github.com/piravelha/GRP-language/assets/140568241/88aabf4a-33f9-493b-8efb-93418c841f11)


### Explanation
Since GRP is a stack-based language, the program is read like a sequence of instructions, from left, to right.

In this case, we have 3 instructions declared as `MyNumber`:
- **`1`**: Pushes *1* onto the stack.
- **`2`**: Pushes *2* onto the stack.
- **`+`**: Sums the two top elements of the stack, popping them, and pushes the result.

After that, we have the evaluation block, which is always the last step of a program.

- **`eval`**: Enters evaluation mode
- **`MyNumber`**: Runs the instructions declared in MyNumber
- **`|<`**: Pops the first element of the stack (`3`) and prints it to the console.

So we expect the result of this program to be `3` (`print(1 + 2)`).

### Making your first program
![Screenshot_20240528-035952_Termux](https://github.com/piravelha/GRP-language/assets/140568241/9d2ac748-9195-4ba9-96d2-052fcc9cd3c9)


In GRP, programs are composed of a series of definitions (or none), and a final expression that then gets evaluated upon running the program.

Definitions are declared using the `::` operator, and their name must start with a capital letter.

You can think of drfinitions as just replacements for repetitive code you otherwise would have to write by hand, node that they are evaluated exactly like if they were inlined.

### Multiline Blocks
![Screenshot_20240528-040733_Termux](https://github.com/piravelha/GRP-language/assets/140568241/efe32c2b-41c8-45f3-9a9b-c0edf32a0a39)

GRP is new-line sensitive, to fix this, multiline blocks were added.

To create one, simply open a set of parenthesis, and inside them you can add as many linebreaks as you want.

### If Statements
![Screenshot_20240528-041448_Termux](https://github.com/piravelha/GRP-language/assets/140568241/34c656ee-7b87-4fdd-bb2f-b7ed4d2ac75e)

If statements, like in any other language, are a way to control the flow of execution of a program. In GRP, they are no different, you write them by putting the condition first, since the if statement evaluates the first thing on the stack (and pops it), the keyword "if", your true case, and an optional keyword "else" with a falze case.

Note that there are no booleans in GRP currently, so false values are defined by 0, and any other value as true.

Some operators that you may find usefull for if statements are `=`, `/=`, `<`, `>`, `<=`, `>=`.
