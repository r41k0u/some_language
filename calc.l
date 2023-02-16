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
expulso return '^';
sonorus return '(';
silencio return ')';
[_[:alpha:]][_[:alnum:]]* {yylval.s = new std::string(yytext); return VAR;}
[0-9]+ {yylval.i=atoi(yytext); return NUMBER;}
[ \t] ;
  
[\n] return 0;
  
. return yytext[0];
  
%%

int yywrap()
{
 return 1;
}