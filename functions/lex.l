/* Companion source code for "flex & bison", published by O'Reilly
 * Media, ISBN 978-0-596-15597-1
 * Copyright (c) 2009, Taughannock Networks. All rights reserved.
 * See the README file for license conditions and contact info.
 * $Header: /home/johnl/flnb/code/RCS/fb3-2.l,v 2.1 2009/11/08 02:53:18 johnl Exp $
 */
/* recognize tokens for the calculator */

%option noyywrap nodefault yylineno
%{
# include "hdr.h"
# include "yacc.tab.h"
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

 /* keywords */

expecto    { return IF; }
patronum  { return ELSE; }
alohomora { return WHILE; }
let   { return LET;}
endif   {return ENDIF;}
enddef  {return ENDDEF;}
makeclass       {return CLASS;}
endclass    {return ENDCLASS;}
makeobj     {return MAKEOBJ;}

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

.	{ yyerror("Mystery character %c\n", *yytext); }
%%