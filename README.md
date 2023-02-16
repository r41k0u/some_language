## Build Steps

```
flex calc.l
yacc -dtv calc.y
g++ -c lex.yy.c
g++ -c y.tab.c
g++ -o calc y.tab.o lex.yy.o
```
