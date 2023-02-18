# The Hogwarts Programming Language :shipit:
Welcome to the Hogwarts Programming Language! This is a project that aims to create a fun and magical programming language inspired by the world of Harry Potter. The language is constructed using lex and yacc, two powerful tools for creating lexical analyzers and parsers.

## Getting Started
To get started with the Hogwarts Programming Language, you'll need to clone this repository and compile the code using the makefile provided. You can do this by running the following commands in your terminal:
```
git clone https://github.com/r41k0u/some_language.git
cd some-language
```
##### Build Steps for the Project!

```
flex calc.l
yacc -dtv calc.y
g++ -c lex.yy.c
g++ -c y.tab.c
g++ -o calc y.tab.o lex.yy.o
```

## Features
The Hogwarts Programming Language is designed to be easy to learn and use, with syntax inspired by the spells and incantations of the Harry Potter universe. Some of the features of the language include:

###### Spellcasting : 
In the Hogwarts Programming Language :shipit: , you can cast spells to perform various operations, such as addition, subtraction, multiplication, and division. For example, the spell *reparo* can be used to add two values, while the spell *diffindo* can be used to remove a value from memory.
###### Control flow : 
The Hogwarts Programming Language supports conditional statements (using spells like expecto and patronum for if and else) and loops (using spells like alhomora for while) to control the flow of your program.

**For a full list of features and syntax, please see the documentation provided in the [docs](https://github.com/r41k0u/some_language/blob/initcalc/docs/README.md) folder.**

## Examples
* 
```
x = 0;
alhomora (x < 100)
{
    lumos x;
    x = x reparo 1;
    expecto (x > 90)
    {
        lumos 1000;
    }
}
```


