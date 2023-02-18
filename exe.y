%{
   /* Definition section */
  #include <stdio.h>
  #include <iostream>
  #include <string>
  #include <map>

  typedef union {
        int value;
        struct nnode *np;
        std::string str;
} ITEM;

  typedef struct nnode {
        int oprtr;
        ITEM left, right, third;
} NODE;

  #define LEFT    left.np
#define RIGHT   right.np

#define NNULL           ((NODE *) 0)
#define node(a,b,c)     triple(a, b, c, NNULL)

  int flag=0;
  static std::map<std::string, int> vars;
  int yylex(void);
  inline void yyerror(const char *s) { std::cout << s << std::endl; flag = 1; std::cout << "Invalid\n";}
  extern FILE *yyin;
  int execute(NODE *np);
  static NODE *nalloc(void);
static NODE *leaf(int typ, int value);
static NODE *leaf_str(int typ, std::string *value);
static NODE *triple(int op, NODE *left, NODE *right, NODE *third);
static void freeall(NODE *np);
int sym[26];
%}

%union {int i; std::string *s; struct nnode *np;}

%token<i> NUMBER 
%token<s> VAR
%token TEMP PRINT LE GE EQ NEQ LT GT AND OR XOR NOT WHILE IF ELSE
%type<np> E stl stmt

%right '^'

%right '='

%left GE NEQ LT GT LE EQ

%left '+' '-'
  
%left '*' '/' '%'

%left AND OR XOR

%left NOT

%left '(' ')'

%right TEMP

/* Rule Section */
%%

prg: prg stmt {execute($2); freeall($2);}
 | prg error ';' {yyerrok;}
 |
 ;

stmt: ';' {$$ = node(';', NNULL, NNULL);}
 | E ';' {$$ = $1;}
 | PRINT E ';' {$$ = node(PRINT, $2, NNULL);}
 | VAR '=' E {$$ = node('=', leaf_str(VAR, $1), $3);}
 | WHILE '(' E ')' stmt {$$ = node(WHILE, $3, $5);}
 | IF '(' E ')' stmt ELSE stmt {$$ = triple(IF, $3, $5, $7);}
 | IF '(' E ')' stmt {$$ = triple(IF, $3, $5, NNULL);}
 | '{' stl '}' {$$ = $2;};

stl: stmt {$$ = $1;}
 | stl stmt {$$ = node(';', $1, $2);};

E: NUMBER {$$ = leaf(NUMBER, $1);}

 | VAR {$$ = leaf_str(VAR, $1);}
 
 | E LT E {$$ = node(LT, $1, $3);}
 
 | E GT E {$$ = node(GT, $1, $3);}

 | E EQ E {$$ = node(EQ, $1, $3);}
 
 | E LE E {$$ = node(LE, $1, $3);}

 | E GE E {$$ = node(GE, $1, $3);}
 
 | E NEQ E {$$ = node(NEQ, $1, $3);}

 | E XOR E {$$ = node(XOR, $1, $3);}

 | E OR E {$$ = node(OR, $1, $3);}

 | E AND E {$$ = node(AND, $1, $3);}

 | NOT E {$$ = node(NOT, $2, NNULL);}
 
 |E '+' E {$$ = node('+', $1, $3);}
  
 |E'-'E {$$ = node('-', $1, $3);}
  
 |E'*'E {$$ = node('*', $1, $3);}
  
 |E'/'E {$$ = node('/', $1, $3);}
  
 |E'%'E {$$ = node('%', $1, $3);}

 | '-' E %prec TEMP {$$ = node('-', NNULL, $2);}
  
 |'('E')' {$$=$2;}

 ;
  
%%
  
//driver code
extern int yylex();
extern int yyparse();
int main(int argc, char** argv)
{
   //yydebug = 1;
   FILE *fp = fopen(argv[2], "r");
   yyin = fp;
   yyparse();
   return 0;
}

static NODE * nalloc()
{
        NODE *np;

        np = (NODE *) malloc(sizeof(NODE));
        if (np == NNULL) {
                printf("Out of Memory\n");
                exit(1);
        }
        return np;
}

static NODE *leaf(int typ, int value)
{
        NODE *np = nalloc();

        np->oprtr = typ;
        np->left.value = value;
        return np;
}

static NODE *leaf_str(int typ, std::string *value)
{
        NODE *np = nalloc();

        np->oprtr = typ;
        np->left.str = *value;
        return np;
}

static NODE *triple(int op, NODE *left, NODE *right, NODE *third)
{
        NODE *np = nalloc();

        np->oprtr = op;
        np->left.np = left;
        np->right.np = right;
        np->third.np = third;
        return np;
}

static void freeall(NODE *np)
{
        if (np == NNULL)
                return;
        switch(np->oprtr) {
        case IF:                /* Triple */
                freeall(np->third.np);
        /* FALLTHROUGH */
                                /* Binary */
        case '+': case '-': case '*': case '/':
        case ';': case GT: case LT:
        case GE: case LE: case NEQ: case EQ:
        case WHILE:
        case '=':
                freeall(np->RIGHT);
        /* FALLTHROUGH */
        case PRINT:             /* Unary */
                freeall(np->LEFT);
                break;
        }
        free(np);
}

int execute(NODE *np)
{
    switch (np->oprtr)
    {
        case NUMBER: return np->left.value;
        case VAR: return vars[np->left.str];
        case '+': return (execute(np->LEFT) + execute(np->RIGHT));
        case '-': return (execute(np->LEFT) - execute(np->RIGHT));
        case '*': return (execute(np->LEFT) * execute(np->RIGHT));
        case '/': return (execute(np->LEFT) / execute(np->RIGHT));
        case GE: return (execute(np->LEFT) >= execute(np->RIGHT));
        case LE: return (execute(np->LEFT) <= execute(np->RIGHT));
        case GT: return (execute(np->LEFT) > execute(np->RIGHT));
        case LT: return (execute(np->LEFT) < execute(np->RIGHT));
        case EQ: return (execute(np->LEFT) == execute(np->RIGHT));
        case NEQ: return (execute(np->LEFT) != execute(np->RIGHT));
        case AND: return (execute(np->LEFT) && execute(np->RIGHT));
        case OR: return (execute(np->LEFT) || execute(np->RIGHT));
        case XOR: return (execute(np->LEFT) ^ execute(np->RIGHT));
        case NOT: return !(np->left.value);
        case PRINT: printf("%d\n", execute(np->LEFT)); return 0;
        case ';': execute(np->LEFT); return execute(np->RIGHT);
        case '=': return vars[np->left.str] = execute(np->RIGHT);
        case WHILE:
            while (execute(np->LEFT))
            {
                execute(np->RIGHT);
            }
            return 0;
        case IF:
            if (execute(np->LEFT))
            {
                execute(np->RIGHT);
            } else if (np->third.np != NNULL) {
                execute(np->third.np);
            }
            return 0;
    }
    printf("Bad node\n");
    exit(1);
}