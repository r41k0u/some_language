/* Companion source code for "flex & bison", published by O'Reilly
 * Media, ISBN 978-0-596-15597-1
 * Copyright (c) 2009, Taughannock Networks. All rights reserved.
 * See the README file for license conditions and contact info.
 * $Header: /home/johnl/flnb/code/RCS/fb3-2.y,v 2.1 2009/11/08 02:53:18 johnl Exp $
 */
/* calculator with AST */

%{
#  include <stdio.h>
#  include <stdlib.h>
#  include "hdr.h"
%}

%union {
  struct ast *a;
  double d;
  struct symbol *s;		/* which symbol */
  struct symlist *sl;
  int fn;			/* which function */
}

/* declare tokens */
%token <d> NUMBER
%token <s> NAME
%token <fn> FUNC
%token EOL

%token IF ELSE WHILE LET ENDIF THEN DO


%nonassoc <fn> CMP
%right '='
%left '+' '-'
%left '*' '/'
%nonassoc '|' UMINUS

%type <a> exp stmt list explist c_stmt o_stmt
%type <sl> symlist

%start calclist

%%

stmt: o_stmt {$$ = $1;}
   | c_stmt {$$ = $1;}
   ;

o_stmt: IF '(' exp ')' stmt ENDIF { $$ = newflow('I', $3, $5, NULL); }
   | IF '(' exp ')' c_stmt ELSE o_stmt ENDIF  { $$ = newflow('I', $3, $5, $7); }
   | WHILE '(' exp ')' o_stmt        { $$ = newflow('W', $3, $5, NULL); }
   ;

c_stmt: exp EOL                   { $$ = $1; }
   | '{' list '}'          { $$ = $2; }
   | EOL                     { $$ = newast('L', NULL, NULL); }
   | IF '(' exp ')' c_stmt ELSE c_stmt ENDIF  { $$ = newflow('I', $3, $5, $7); }
   | WHILE '(' exp ')' c_stmt        { $$ = newflow('W', $3, $5, NULL); }
   ;

list: stmt
   | list stmt {$$ = newast('L', $1, $2);}
   ;

exp: exp CMP exp          { $$ = newcmp($2, $1, $3); }
   | exp '+' exp          { $$ = newast('+', $1,$3); }
   | exp '-' exp          { $$ = newast('-', $1,$3);}
   | exp '*' exp          { $$ = newast('*', $1,$3); }
   | exp '/' exp          { $$ = newast('/', $1,$3); }
   | '|' exp              { $$ = newast('|', $2, NULL); }
   | '(' exp ')'          { $$ = $2; }
   | '-' exp %prec UMINUS { $$ = newast('M', $2, NULL); }
   | NUMBER               { $$ = newnum($1); }
   | FUNC '(' explist ')' { $$ = newfunc($1, $3); }
   | NAME                 { $$ = newref($1); }
   | NAME '=' exp         { $$ = newasgn($1, $3); }
   | NAME '(' explist ')' { $$ = newcall($1, $3); }
;

explist: exp
 | exp ',' explist  { $$ = newast('L', $1, $3); }
;
symlist: NAME       { $$ = newsymlist($1, NULL); }
 | NAME ',' symlist { $$ = newsymlist($1, $3); }
;

calclist: /* nothing */
  | calclist stmt {
     eval($2);
     treefree($2);
    }
  | calclist LET NAME '(' symlist ')' '=' list {
                       dodef($3, $5, $8);
                       printf("Defined %s\n> ", $3->name); }

  | calclist error EOL { yyerrok; }
 ;
%%
int
main()
{
  //yydebug = 1;
  return yyparse();
}