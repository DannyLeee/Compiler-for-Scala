%{
#include <stdlib.h>
#include "symbolTable.h"
#include "lex.yy.c"
#define Trace(t)        printf(t)

void yyerror(char *msg)
{
    fprintf(stderr, "%s\n", msg);
}

vector <table> sTableList;
int current_t;
%}

%union {
    int intVal;
    entry* entryPt;
    string* strVal;
    double realVal;
    bool boolVal;
    dataType typeVal;
}



/* keyword tokens */
%token SEMICOLON BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT NULL_ OBJECT PRINT PRINTLN READ REPEAT RETURN STRING TO TYPE VAL VAR WHILE

/* other tokens */
%token OR AND LES LEQ EQU GRT GEQ NEQ

%token NTYPE

%type <entryPt> constant_exp num
%type <boolVal> bool_exp
%type <typeVal> type_

%token <strVal> STRING_ ID
%token <intVal> INTEGER
%token <realVal> REAL
%token <boolVal> TRUE FALSE

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
constant_exp:   STRING_
                {
                    
                    entry* temp = new entry(STR_, new string(*$1), true);
                    $$ = temp;
                } |
                num
                {
                    $$ = $1;
                } |
                TRUE | FALSE
                {
                    entry* temp = new entry(BOOLEAN_, $1, true);
                    $$ = temp;
                };

// TODO: invalid conversion from ‘int’ to ‘dataType’
type_:          ':' CHAR
                {
                    $$ = CHAR_;
                } |
                ':' STRING
                {
                    $$ = STRING_;
                } |
                ':' INT
                {
                    $$ = INT_;
                } |
                ':' BOOLEAN 
                {
                    $$ = BOOLEAN_;
                }|
                ':' FLOAT 
                {
                    $$ = REAL_;
                } |
                {
                    $$ = NTYPE;
                };

const_declar:   VAL ID type_ '=' constant_exp
                {
                    // TODO
                    // insert symbol table
                    if ($3 == NTYPE)
                    {
                        sTableList[current_t].insert(*$2, *$5);
                    }
                    else
                    {
                        if ($3 == $5->dType)
                        {
                            Trace("Reducing to constant declar\n");
                            sTableList[current_t].insert(*$2, *$5);
                        }
                        else
                        {
                            yyerror("type error");
                        }
                    }
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
                    // TODO: open a new sumbol table
                };

formal_arguments: ID type_ formal_arguments | ;

_0_or_more_stmts: stmts _0_or_more_stmts | ;
method_declar:  DEF ID '(' formal_arguments ')' type_ '{' _0_or_more_CONST_VAR  _0_or_more_stmts '}'
                {
                    // TODO: insert symbol table
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
                int_exp |
                bool_exp
                {
                    // TODO
                    // $$ = $1;
                } |
                '(' exp ')' |
                '[' int_exp ']'
                {
                    // $$ = $2;
                };
    // TODO ??
int_exp:        num 
                {
                    // $$ = $1->intVal;
                } |
                exp '+' exp
                {
                    // TODO
                    // $$ = $1->intVal + $3->intVal;
                } |
                exp '-' exp
                {
                    // TODO
                    // $$ = $1->intVal - $3->intVal;
                } |
                exp '*' exp 
                {
                    // TODO
                    // $$ = $1->intVal * $3->intVal;
                } |
                exp '/' exp 
                {
                    // TODO
                    // $$ = $1->intVal / $3->intVal;
                };

    // simple
simple_stmts:   RETURN |
                READ ID |
                PRINT exp |
                RETURN exp |
                PRINTLN exp |
                ID '=' exp 
                {
                    // TODO: assign the value to ID
                } |
                ID '[' int_exp ']' '=' exp |
                {
                    // TODO: assign the value to ID[i]
                };

    // function invocation
comma_separate_exp: constant_exp |
                    constant_exp ',' comma_separate_exp | ;

func_invocate:  ID '(' comma_separate_exp ')'
                {
                    // TODO: check parameters' data type
                };

    // block
_1_or_more_stmts: stmts | stmts _1_or_more_stmts;
block:          '{' _0_or_more_CONST_VAR _1_or_more_stmts '}'
                {
                    // TODO: new a symbol table
                };

    // conditional
bool_exp:       '!' exp 
                {
                    // TODO
                    // $$ = !$2;
                } |
                exp LES exp 
                {
                    // TODO
                    // $$ = $1 < $3;
                } |
                exp GRT exp 
                {
                    // TODO
                    // $$ = $1 > $3;
                } |
                exp LEQ exp 
                {
                    // TODO
                    // $$ = $1 <= $3;
                } |
                exp EQU exp 
                {
                    // TODO
                    // $$ = $1 == $3;
                } |
                exp GEQ exp 
                {
                    // TODO
                    // $$ = $1 >= $3;
                } |
                exp NEQ exp 
                {
                    // TODO
                    // $$ = $1 != $3;
                } |
                exp AND exp 
                {
                    // TODO
                    // $$ = $1 && $3;
                } |
                exp OR exp
                {
                    // TODO
                    // $$ = $1 || $3;
                };

conditional:    IF '(' bool_exp ')' block |
                IF '(' bool_exp ')' simple_stmts |
                IF '(' bool_exp ')' block ELSE block |
                IF '(' bool_exp ')' block ELSE simple_stmts |
                IF '(' bool_exp ')' simple_stmts ELSE block |
                IF '(' bool_exp ')' simple_stmts ELSE simple_stmts;

    // loop
num:            REAL
                {
                    entry* temp = new entry(REAL_, $1, true);
                    $$ = temp;
                } |
                INTEGER
                {
                    entry* temp = new entry(INT_, $1, true);
                    $$ = temp;
                }

loop:           WHILE '(' bool_exp ')' block |
                WHILE '(' bool_exp ')' simple_stmts |
                FOR '(' ID '<''-' num TO num ')' block |
                FOR '(' ID '<''-' num TO num ')' simple_stmts;

    /* procedure invocation */
procedure_invocate: ID |
                    ID '(' comma_separate_exp ')'
                    {
                        // TODO: check parameters' data type
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

    table mainTable;
    sTableList.push_back(mainTable);
    current_t = 1;

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !");     /* syntax error */
}