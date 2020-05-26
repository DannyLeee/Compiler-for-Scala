%{
#include <stdlib.h>
#include "lex.yy.c"
#define Trace(t)        printf(t)

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

%}

/* tokens */
%token SEMICOLON identifier

%%
program:        identifier semi
                {
                Trace("Reducing to program\n");
                }
                ;

semi:           SEMICOLON
                {
                Trace("Reducing to semi\n");
                }
                ;
%%

int main(int argc, char *argv[])
{
    /* open the source program file */
    if (argc != 2) {
        printf ("Usage: sc filename\n");
        exit(1);
    }
    yyin = fopen(argv[1], "r");         /* open input file */

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
}