#  include <stdio.h>
#  include <stdlib.h>
#  include <stdarg.h>
#  include <string.h>
#  include <math.h>
#  include "hdr.h"

/* symbol table */
struct symbol symtab[NHASH];

/* hash a symbol */
static unsigned
calculate_hash(char *sym)
{
  unsigned int hash = 0;
  unsigned c;

  while(c == *sym++) hash = hash*9 ^ c;

  return hash;
}

struct ast *
create_ast(int nodetype, struct ast *l, struct ast *r)
{
  struct ast *a = malloc(sizeof(struct ast));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = nodetype;
  a->r = r;
  a->l = l;
  
  return a;
}

struct symbol *
find_or_create_symbol(char* sym)
{
  struct symbol *sp = &symtab[calculate_hash(sym) % NHASH];
  int scount = NHASH;    /* how many have we looked at */

  while (--scount >= 0) {
    if (sp->name && !strcmp(sp->name, sym)) {
      return sp; // found symbol, return pointer to it
    }

    if (!sp->name) {    /* new entry */
      sp->name = strdup(sym);
      sp->value = 0;
      sp->func = NULL;
      sp->syms = NULL;
      return sp; // created new symbol, return pointer to it
    }

    if (++sp >= symtab + NHASH) sp = symtab; /* try the next entry */
  }

  yyerror("symbol table overflow\n");
  abort(); // tried them all, table is full
}

struct ast *
newcmp(int cmptype, struct ast *l, struct ast *r)
{
  struct ast *a = malloc(sizeof(struct ast));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = '0' + cmptype;
  a->l = l;
  a->r = r;
  return a;
}

struct symlist *
new_symbol_list_node(struct symbol *symbol, struct symlist *next_node)
{
  struct symlist *new_node = malloc(sizeof(struct symlist));
  
  if(!new_node) {
    yyerror("out of space");
    exit(0);
  }
  new_node->sym = symbol;
  new_node->next = next_node;
  return new_node;
}

void freesymlist(struct symlist *list)
{
  struct symlist *next;

  while(list) {
    next = list->next;
    free(list);
    list = next;
  }
}

struct ast *newnum(double val) {
  struct numval *node = malloc(sizeof(struct numval));
  
  if(!node) {
    yyerror("out of space");
    exit(0);
  }

  node->nodetype = 'K';
  node->number = val;
  return (struct ast *)node;
}

struct ast *
newcall(struct symbol *s, struct ast *l)
{
  struct ufncall *a = malloc(sizeof(struct ufncall));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'C';
  a->l = l;
  a->s = s;
  return (struct ast *)a;
}

struct ast *
newfunc(int functype, struct ast *l)
{
  struct fncall *a = malloc(sizeof(struct fncall));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = 'F';
  a->l = l;
  a->functype = functype;
  return (struct ast *)a;
}

struct ast *
newref(struct symbol *s)
{
  struct symref *ref = malloc(sizeof(struct symref));
  
  if(!ref) {
    yyerror("out of space");
    exit(0);
  }
  ref->nodetype = 'N';
  ref->s = s;
  return (struct ast *)ref;
}

struct ast *
create_assignment(struct symbol *s, struct ast *v)
{
  if (!s) {
    yyerror("undefined variable");
    exit(1);
  }
  struct symasgn *a = malloc(sizeof(struct symasgn));
  
  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  a->nodetype = '=';
  a->v = v;
  a->s = s;
  
  return (struct ast *)a;
}

struct ast *
newflow(int nodetype, struct ast *condition, struct ast *true_branch, struct ast *false_branch)
{
  struct flow *flow_node = malloc(sizeof(struct flow));
  
  if(!flow_node) {
    yyerror("out of space");
    exit(0);
  }
  flow_node->nodetype = nodetype;
  flow_node->cond = condition;
  flow_node->tl = true_branch;
  flow_node->el = false_branch;
  return (struct ast *)flow_node;
}

/* define a function */
void
dodef(struct symbol *name, struct symlist *syms, struct ast *func)
{
  if(name->syms) freesymlist(name->syms);
  if(name->func) treefree(name->func);
  name->syms = syms;
  name->func = func;
}

static double callbuiltin(struct fncall *);
static double calluser(struct ufncall *);

double
eval(struct ast *a)
{
  double v;

  if(!a) {
    //yyerror("internal error, null eval");
    return 0;
  }

  switch(a->nodetype) {
    /* constant */
  case 'K': v = ((struct numval *)a)->number; break;

    /* name reference */
  case 'N': v = ((struct symref *)a)->s->value; break;

    /* assignment */
  case '=': v = ((struct symasgn *)a)->s->value =
      eval(((struct symasgn *)a)->v); break;

    /* expressions */
  case '+': v = eval(a->l) + eval(a->r); break;
  case '-': v = eval(a->l) - eval(a->r); break;
  case '*': v = eval(a->l) * eval(a->r); break;
  case '/': v = eval(a->l) / eval(a->r); break;
  case '|': v = fabs(eval(a->l)); break;
  case 'M': v = -eval(a->l); break;

    /* comparisons */
  case '1': v = (eval(a->l) > eval(a->r))? 1 : 0; break;
  case '2': v = (eval(a->l) < eval(a->r))? 1 : 0; break;
  case '3': v = (eval(a->l) != eval(a->r))? 1 : 0; break;
  case '4': v = (eval(a->l) == eval(a->r))? 1 : 0; break;
  case '5': v = (eval(a->l) >= eval(a->r))? 1 : 0; break;
  case '6': v = (eval(a->l) <= eval(a->r))? 1 : 0; break;

  /* control flow */
  /* null if/else/do expressions allowed in the grammar, so check for them */
  case 'I': 
    if( eval( ((struct flow *)a)->cond) != 0) {
      if( ((struct flow *)a)->tl) {
	v = eval( ((struct flow *)a)->tl);
      } else
	v = 0.0;		/* a default value */
    } else {
      if( ((struct flow *)a)->el) {
        v = eval(((struct flow *)a)->el);
      } else
	v = 0.0;		/* a default value */
    }
    break;

  case 'W':
    v = 0.0;		/* a default value */
    
    if( ((struct flow *)a)->tl) {
      while( eval(((struct flow *)a)->cond) != 0)
	v = eval(((struct flow *)a)->tl);
    }
    break;			/* last value is value */
	              
  case 'L': eval(a->l); v = eval(a->r); break;

  case 'F': v = callbuiltin((struct fncall *)a); break;

  case 'C': v = calluser((struct ufncall *)a); break;

  default: printf("internal error: bad node %c\n", a->nodetype);
  }
  return v;
}

static double
callbuiltin(struct fncall *f)
{
  enum bifs functype = f->functype;
  double v = eval(f->l);

 switch(functype) {
 case B_sqrt:
   return sqrt(v);
 case B_exp:
   return exp(v);
 case B_log:
   return log(v);
 case B_print:
   printf("%4.4g\n", v);
   return v;
 default:
   yyerror("Unknown built-in function %d", functype);
   return 0.0;
 }
}

static double calluser(struct ufncall *func)
{
  struct symbol *fn = func->s;	/* function name */
  struct symlist *dummy_args;	/* dummy arguments */
  struct ast *actual_args = func->l;	/* actual arguments */
  double *old_val, *new_val;	/* saved arg values */
  double result;
  int num_args;
  int i;

  if (!fn->func) {
    yyerror("call to undefined function", fn->name);
    return 0;
  }

  /* count the arguments */
  dummy_args = fn->syms;
  for (num_args = 0; dummy_args; dummy_args = dummy_args->next)
    num_args++;

  /* prepare to save them */
  old_val = (double *)malloc(num_args * sizeof(double));
  new_val = (double *)malloc(num_args * sizeof(double));
  if (!old_val || !new_val) {
    yyerror("Out of space in %s", fn->name);
    return 0.0;
  }
  
  /* evaluate the arguments */
  for (i = 0; i < num_args; i++) {
    if (!actual_args) {
      yyerror("too few args in call to %s", fn->name);
      free(old_val); 
      free(new_val);
      return 0;
    }

    if (actual_args->nodetype == 'L') {	/* if this is a list node */
      new_val[i] = eval(actual_args->l);
      actual_args = actual_args->r;
    } else {			/* if it's the end of the list */
      new_val[i] = eval(actual_args);
      actual_args = NULL;
    }
  }
		     
  /* save old values of dummies, assign new ones */
  dummy_args = fn->syms;
  for (i = 0; i < num_args; i++) {
    struct symbol *sym = dummy_args->sym;

    old_val[i] = sym->value;
    sym->value = new_val[i];
    dummy_args = dummy_args->next;
  }

  free(new_val);

  /* evaluate the function */
  result = eval(fn->func);

  /* put the dummies back */
  dummy_args = fn->syms;
  for (i = 0; i < num_args; i++) {
    struct symbol *sym = dummy_args->sym;

    sym->value = old_val[i];
    dummy_args = dummy_args->next;
  }

  free(old_val);
  return result;
}


void
treefree(struct ast *a)
{
  switch(a->nodetype) {

    /* two subtrees */
  case '+':
  case '-':
  case '*':
  case '/':
  case '1':  case '2':  case '3':  case '4':  case '5':  case '6':
  case 'L':
    treefree(a->r);

    /* one subtree */
  case '|':
  case 'M': case 'C': case 'F':
    treefree(a->l);

    /* no subtree */
  case 'K': case 'N':
    break;

  case '=':
    free( ((struct symasgn *)a)->v);
    break;

  case 'I': case 'W':
    free( ((struct flow *)a)->cond);
    if( ((struct flow *)a)->tl) free( ((struct flow *)a)->tl);
    if( ((struct flow *)a)->el) free( ((struct flow *)a)->el);
    break;

  default: printf("internal error: free bad node %c\n", a->nodetype);
  }	  
  
  free(a); /* always free the node itself */

}

void
yyerror(char *s, ...)
{
  va_list ap;
  va_start(ap, s);

  fprintf(stderr, "%d: error: ", yylineno);
  vfprintf(stderr, s, ap);
  fprintf(stderr, "\n");
}