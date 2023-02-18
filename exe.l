%{
   /* Definition section */
  #include <stdio.h>
  #include <string>
  #include "y.tab.h"
%}
%%

reparo return '+';
diffindo return '-';
reducto return '/';
portus return '*';
duro return '%';
expulso return XOR;
lumos return PRINT;
ascendio return AND;
avifors return OR;
confringo return NOT;
equo return EQ;
amato return GE;
animo return LE;
anapneo return GT;
calvorio return LT;
confundo return NEQ;
alohomora return WHILE;
expecto return IF;
patronum return ELSE;
[_[:alpha:]][_[:alnum:]]* {yylval.i = ((char) yytext[0]) - 'a'; return VAR;}
[0-9]+ {yylval.i=atoi(yytext); return NUMBER;}
[ \t\n] ; 
  
. return yytext[0];
  
%%

int yywrap()
{
 return 1;
}