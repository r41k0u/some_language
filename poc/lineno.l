%{
 int yylineno;
%}

%%

^(.*)\n printf("%4d\t%s\n", ++yylineno - 1, yytext);

%%

int main(int argc, char *argv[]) {
 yyin = fopen(argv[1], "r");
 yylex();
 fclose(yyin);
} 