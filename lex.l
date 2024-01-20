%option noyywrap nodefault yylineno
%{
# include "hdr.h"
# include "y.tab.h"
%}

/* float exponent */
EXP	([Ee][-+]?[0-9]+)

%%
 /* single character ops */
reparo return '+';
diffindo return '-';
reducto return '/';
portus return '*';
duro return '%';
"=" |
"|" |
"," |
"(" |
"{" |
"}" |
")"     { return yytext[0]; }


 /* comparison ops */
anapneo     { yylval.fn = 1; return CMP; }
calvorio     { yylval.fn = 2; return CMP; }
confundo    { yylval.fn = 3; return CMP; }
equo    { yylval.fn = 4; return CMP; }
amato    { yylval.fn = 5; return CMP; }
animo    { yylval.fn = 6; return CMP; }
expulso  { yylval.fn = 7; return XOR; }
ascendio { yylval.fn = 8; return AND; }
avifors  { yylval.fn = 9; return OR; }
confringo { yylval.fn = 10; return NOT; }

 /* keywords */

expecto    { return IF; }
patronum  { return ELSE; }
alohomora { return WHILE; }
spell   { return LET;}
endif   {return ENDIF;}
enddef  {return ENDDEF;}
aparecium       {return CLASS;}
endclass    {return ENDCLASS;}
accio     {return MAKEOBJ;}

 /* built in functions */
"sqrt"  { yylval.fn = B_sqrt; return FUNC; }
"exp"   { yylval.fn = B_exp; return FUNC; }
"log"   { yylval.fn = B_log; return FUNC; }
"lumos" { yylval.fn = B_print; return FUNC; }

 /* names */
[a-zA-Z][a-zA-Z0-9]*  { yylval.s = find_or_create_symbol(yytext); return NAME; }

[0-9]+"."[0-9]*{EXP}? |
"."?[0-9]+{EXP}? { yylval.d = atof(yytext); return NUMBER; }
[ \t\n]   /* ignore white space */
\\\n    printf("c> "); /* ignore line continuation */
";"    { return EOL; }
"/*"([^*]|\*+[^*/])*\*+"/"

[a-zA-Z][a-zA-Z0-9]*=>[a-zA-Z][a-zA-Z0-9]* { yylval.s = find_or_create_symbol(yytext); return NAME; }
.	{ yyerror("Mystery character %c\n", *yytext); }
%%