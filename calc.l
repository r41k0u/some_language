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
== return EQ;
\<= return GE;
=< return LE;
> return GT;
\< return LT;
!= return NEQ;
[_[:alpha:]][_[:alnum:]]* {yylval.s = new std::string(yytext); return VAR;}
\"[^"\n]*["\n] {yylval.s = new std::string(yytext); return STR;}
[0-9]+ {yylval.i=atoi(yytext); return NUMBER;}
[ \t] ;
  
[\n] return 0;
  
. return yytext[0];
  
%%

int yywrap()
{
 return 1;
}