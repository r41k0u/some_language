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

extern FILE *yyin;
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

%token IF ELSE WHILE LET ENDIF ENDDEF CLASS ENDCLASS MAKEOBJ

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
   | EOL                     { $$ = create_ast('L', NULL, NULL); }
   | IF '(' exp ')' c_stmt ELSE c_stmt ENDIF  { $$ = newflow('I', $3, $5, $7); }
   | WHILE '(' exp ')' c_stmt        { $$ = newflow('W', $3, $5, NULL); }
   | CLASS NAME NAME EOL ENDCLASS   {$$ = create_ast('L', NULL, NULL);}
   | CLASS NAME LET NAME '(' symlist ')' '=' list ENDDEF ENDCLASS {$$ = create_ast('L', NULL, NULL);}
   | MAKEOBJ NAME NAME EOL {$$ = create_ast('L', NULL, NULL);}
   ;

list: stmt
   | list stmt {$$ = create_ast('L', $1, $2);}
   ;

exp: exp CMP exp          { $$ = newcmp($2, $1, $3); }
   | exp '+' exp          { $$ = create_ast('+', $1,$3); }
   | exp '-' exp          { $$ = create_ast('-', $1,$3);}
   | exp '*' exp          { $$ = create_ast('*', $1,$3); }
   | exp '/' exp          { $$ = create_ast('/', $1,$3); }
   | '|' exp              { $$ = create_ast('|', $2, NULL); }
   | '(' exp ')'          { $$ = $2; }
   | '-' exp %prec UMINUS { $$ = create_ast('M', $2, NULL); }
   | NUMBER               { $$ = newnum($1); }
   | FUNC '(' explist ')' { $$ = newfunc($1, $3); }
   | NAME                 { $$ = newref($1); }
   | NAME '=' exp         { $$ = create_assignment($1, $3); }
   | NAME '(' explist ')' { $$ = newcall($1, $3); }
;

explist: exp
 | exp ',' explist  { $$ = create_ast('L', $1, $3); }
;
symlist: NAME       { $$ = new_symbol_list_node($1, NULL); }
 | NAME ',' symlist { $$ = new_symbol_list_node($1, $3); }
;

calclist: /* nothing */
  | calclist stmt {
     eval($2);
     treefree($2);
    }
  | calclist LET NAME '(' symlist ')' '=' list ENDDEF {
                       dodef($3, $5, $8);
                       printf("Defined %s\n", $3->name); }

  | calclist error EOL { yyerrok; }
 ;

%%
int main(int argc, char *argv[])
{
   if (argc < 2) {
      //   fprintf(stderr, "Usage: %s input_file\n", argv[0]);
      //   return 1;
      return yyparse();
    }

    FILE *input_file = fopen(argv[1], "r");
    if (!input_file) {
        perror("Error opening input file");
        return 1;
    }


    yyin = input_file;  // assign file pointer to yyin
    yyparse();
    fclose(input_file);  // close the input file

   return 0;
}