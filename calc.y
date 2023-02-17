%{
   /* Definition section */
  #include <stdio.h>
  #include <iostream>
  #include <string>
  #include <map>

  int flag=0;
  static std::map<std::string, int> vars;
  int yylex(void);
  inline void yyerror(const char *s) { std::cout << s << std::endl; flag = 1; std::cout << "Invalid\n";}
  extern FILE *yyin;
%}

%union {int i; std::string *s;}

%token<i> NUMBER 
%token<s> VAR 
%token TEMP
%type<i> E
%type<i> ArithmeticExpression

%right '='

%left '+' '-'
  
%left '*' '/' '%'
  
%left '(' ')'

%right TEMP
  
/* Rule Section */
%%
  
ArithmeticExpression: E{
  
         printf("\nResult=%d\n", $$);
  
         return 0;
  
        };
 E : NUMBER {$$=$1;}

 | VAR {$$ = vars[*$1]; delete $1;}

 | VAR '=' E {$$ = vars[*$1] = $3; delete $1;}
 
 |E'+'E {$$ = $1 + $3;}
  
 |E'-'E {$$=$1-$3;}
  
 |E'*'E {$$=$1*$3;}
  
 |E'/'E {$$=$1/$3;}
  
 |E'%'E {$$=$1%$3;}

 | '+' E %prec TEMP {$$ = $2;}

 | '-' E %prec TEMP {$$ = -$2;}
  
 |'('E')' {$$=$2;}

 ;
  
%%
  
//driver code
extern int yylex();
extern int yyparse();
int main(int argc, char** argv)
{
   if (argc != 3) {
      printf("Incorrect usage\n USAGE:\n ./calc [INPUT FILE] [NUMBER OF LINES IN INPUT]\n");
      return 1;
   }
   //printf("\nEnter Any Arithmetic Expression which can have operations Addition, Subtraction, Multiplication, Division, Modulus and Round brackets:\n");
   FILE *fp;
   if ((fp = fopen(argv[1], "r")) == nullptr) {
      printf("Input file doesn't exist\n");
      return 1;
   }
   yyin = fp;

   for (int i = 0; i < atoi(argv[2]); i++) {
   yyparse();}
   if(flag==0)
   printf("\nEntered arithmetic expression is Valid\n\n");

   return 0;
}