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
%token ID REAL INTEGER STRING_ OR AND LES LEQ EQU GRT GEQ NEQ

%left OR
%left AND
%left '!'
%left LES LEQ EQU GRT GEQ NEQ
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%
program:    obj_declar program | 
            {
                Trace("Reducing to program\n");
            };

    /* Data Types and Declarations */
    // any type of the variable expression
constant_exp:   STRING_ | num | TRUE | FALSE
                {
                    // TODO
                };

type_:          ':' CHAR | ':' STRING |
                ':' INT | ':' BOOLEAN |
                ':' FLOAT | ;

const_declar:   VAL ID type_ '=' constant_exp |
                {
                    // TODO
                    // insert symbol table
                };

var_declar:     VAR ID type_ |
                VAR ID type_ '=' constant_exp
                {
                    // TODO
                    // insert symbol table
                };

array_declar:   VAR ID type_ '[' INTEGER ']'
                {
                    // TODO
                    // insert symbol table
                };

    /* Program Units */
_0_or_more_CONST_VAR:  const_declar | var_declar | array_declar |;
_1_or_more_method:   method_declar | method_declar _1_or_more_method;

obj_declar:     OBJECT ID '{' _0_or_more_CONST_VAR _1_or_more_method '}'
                {
                    // TODO
                };

formal_arguments: ID type_ formal_arguments | ;

_0_or_more_stmts: stmts _0_or_more_stmts | ;
method_declar:  DEF ID '(' formal_arguments ')' type_ '{' _0_or_more_CONST_VAR  _0_or_more_stmts '}'
                {
                    // TODO
                };

    /* Statements */
stmts:          exp | simple_stmts | block |
                conditional | loop | procedure_invocate ;

    // TODO ??
var_name:       ID
                {
                    // TODO: lookup the symbol table and return with type is variable else error
                };
exp:            constant_exp |
                var_name |
                func_invocate |
                '[' int_exp ']' |
                int_exp |
                bool_exp |
                '(' exp ')'
                {
                    // TODO
                };
    // TODO ??
int_exp:        num |
                exp '+' exp |
                exp '-' exp |
                exp '*' exp |
                exp '/' exp 
                {
                    // TODO
                };

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
comma_separate_exp: constant_exp |
                    constant_exp ',' comma_separate_exp | 
                    {
                        // TODO
                    };

func_invocate:  ID '(' comma_separate_exp ')'
                {
                    // TODO
                };

    // block
_1_or_more_stmts: stmts | stmts _1_or_more_stmts;
block:          '{' _0_or_more_CONST_VAR _1_or_more_stmts '}'
                {
                    // TODO
                };

    // conditional
bool_exp:       exp '<' exp |
                exp '>' exp |
                exp '!' exp |
                exp LEQ exp |
                exp EQU exp |
                exp GEQ exp |
                exp NEQ exp |
                exp AND exp |
                exp OR exp
                {
                    // TODO
                };

conditional:    IF '(' bool_exp ')' block |
                IF '(' bool_exp ')' simple_stmts |
                IF '(' bool_exp ')' block ELSE block |
                IF '(' bool_exp ')' block ELSE simple_stmts |
                IF '(' bool_exp ')' simple_stmts ELSE block |
                IF '(' bool_exp ')' simple_stmts ELSE simple_stmts
                {
                    // TODO
                };

    // loop
num:            REAL | INTEGER
                {
                    // TODO
                };

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