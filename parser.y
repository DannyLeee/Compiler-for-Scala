%{
#include <stdlib.h>
#include "symbolTable.h"
#include "lex.yy.c"
#define Trace(t)        printf(t)

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

%}

/* keyword tokens */
%token SEMICOLON BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FALSE FLOAT FOR IF INT NULL OBJECT PRINT PRINTLN READ REPEAT RETURN STRING TO TRUE TYPE VAL VAR WHILE

/* other tokens */
%token ID REAL INTEGER STRING_

%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%
program:    simple_stmts // TODO
            {
                Trace("Reducing to program\n");
            };

    /* Data Types and Declarations */

constant_exp: {};   // TODO

type_:          ':' CHAR | ':' STRING |
                ':' INT | ':' BOOLEAN |
                ':' FLOAT | ;

const_declar:   VAL ID type_ '=' constant_exp |
                {
                    // insert symbol table
                };

var_declar:     VAR ID type_ |
                VAR ID type_ '=' constant_exp
                {
                    // insert symbol table
                };

array_declar:   VAR ID type_ '[' INTEGER ']'
                {
                    // insert symbol table
                };

    /* Program Units */
obj_declar:     OBJECT ID '{' /* <zero or more variable and constant declarations>
one or more method declarations */ '}'
                {
                    // TODO
                };

formal_arguments: ID type_ formal_arguments | ;

method_declar:  DEF ID '(' formal_arguments ')' type_ '{' /* <zero or more constant and variable declarations>
<zero or more statements>
 */ '}'
                {
                    // TODO
                };

    /* Statements */
exp:    {}; // TODO
int_exp:    {}; // TODO

    // simple
simple_stmts:   ID '=' exp |
                ID '[' int_exp ']' '=' exp |
                PRINT '(' exp ')' |
                PRINTLN '(' exp ')' |
                READ ID |
                RETURN |
                RETURN exp
                {
                    // TODO
                };

    // function invocation
comma_separate_exp: /* TODO */ | {};  // TODO

func_invocate:  ID '(' comma_separate_exp ')'
                {
                    // TODO
                };

    // block
block:          '{' /* <zero or more variable and constant declarations>
<one or more statements>
 */ '}'

    // conditional
bool_exp:       {}; // TODO

conditional:    IF '(' bool_exp ')' block |
                IF '(' bool_exp ')' simple_stmts |
                IF '(' bool_exp ')' block ELSE block |
                IF '(' bool_exp ')' block ELSE simple_stmts |
                IF '(' bool_exp ')' simple_stmts ELSE block |
                IF '(' bool_exp ')' simple_stmts simple_stmts
                {
                    // TODO
                };

    // loop
num: {};    // TODO

loop:           WHILE '(' bool_exp ')' block |
                WHILE '(' bool_exp ')' simple_stmts |
                FOR '(' ID '<''-' num TO num ')' block |
                FOR '(' ID '<''-' num TO num ')' simple_stmts
                {
                    // TODO
                };

    /* procedure invocation */
procedure_invocate: ID |
                    ID '(' comma_separate_exp ')'
                    {
                        // TODO
                    };




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