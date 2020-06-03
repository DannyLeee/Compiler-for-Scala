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
}



/* keyword tokens */
%token SEMICOLON BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT NULL_ OBJECT PRINT PRINTLN READ REPEAT RETURN STRING TO TYPE VAL VAR WHILE

/* other tokens */
%token OR AND LES LEQ EQU GRT GEQ NEQ

%token NTYPE

%type <entryPt> constant_exp num exp bool_exp var_name
%type <intVal> type_

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
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2) == -1)
                    {
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
                                yyerror("type error\n");
                        }
                    }
                    else
                        yyerror("conflicting declaration\n");
                };

var_declar:     VAR ID type_
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2) == -1)
                    {
                        // insert symbol table
                        if ($3 == NTYPE)
                        {
                            entry temp;
                            sTableList[current_t].insert(*$2, temp);
                        }
                        else
                        {
                            dataType t = static_cast <dataType> ($3);   // int to enum
                            entry temp(t);
                            sTableList[current_t].insert(*$2, temp);
                        }
                    }
                    else
                        yyerror("conflicting declaration\n");
                } |
                VAR ID type_ '=' constant_exp
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2) == -1)
                    {
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
                                yyerror("type error\n");
                            }
                        }
                    }
                    else
                        yyerror("conflicting declaration\n");
                };

array_declar:   VAR ID type_ '[' exp ']'
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2) == -1)
                    {
                        // insert symbol table
                        if ($3 == NTYPE)
                            yyerror("array don't has type\n");
                        else if ($5->dType != INT_)
                            yyerror("not integer inside []\n");
                        else
                        {
                            dataType t = static_cast <dataType> ($3);   // int to enum
                            sTableList[current_t].insert(*$2, t, $5->val.iVal);
                        }
                    }
                    else
                        yyerror("conflicting declaration\n");
                };

    /* Program Units */
_0_or_more_CONST_VAR:  const_declar | var_declar | array_declar | ;
_1_or_more_method:   method_declar | method_declar _1_or_more_method;

obj_declar:     OBJECT ID '{'
                {
                    // open a new symbol table
                    table new_t;
                    sTableList.push_back(new_t);
                } _0_or_more_CONST_VAR _1_or_more_method '}'
                {
                    // delete the table in block
                    sTableList.pop_back();
                };

formal_arguments:   ID type_ formal_arguments
                    {
                        // TODO
                    } | ;

_0_or_more_stmts: stmts _0_or_more_stmts | ;
method_declar:  DEF ID '(' formal_arguments ')' type_ block
                {
                    // TODO ??
                };

    /* Statements */
stmts:          exp | simple_stmts | block |
                conditional | loop | procedure_invocate ;

var_name:       ID
                {
                    // lookup the symbol table and return variable's name
                    if (sTableList[current_t].lookup(*$1) != -1)
                    {
                        entry temp(NAME_, $1, true);
                        *$$ = temp; // return an entry dType: NAME_, value: ID 
                    }
                    else
                        yyerror("no variable name\n");
                };

exp:            num 
                {
                    $$ = $1;
                } |
                exp '+' exp
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 + *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp '-' exp
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                    {
                        *$$ = *$1 - *$3;
                    }
                    else 
                    {
                        yyerror("type error\n");
                    }
                } |
                exp '*' exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 * *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp '/' exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 / *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp '%' exp
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                        *$$ = *$1 % *$3;
                    else 
                        yyerror("type error\n");
                } |
                '-' exp %prec UMINUS
                {
                    if ($2->dType == INT_ || $2->dType == REAL_)
                        *$$ = -(*$2);
                    else 
                        yyerror("type error\n");
                } |
                constant_exp | bool_exp | func_invocate | var_name
                {
                    $$ = $1;
                } |
                '(' exp ')'
                {
                    $$ = $2;
                } |
                '[' exp ']'
                {
                    // check [exp] is int or error
                    if ($2->dType == INT_)
                        $$ = $2;
                    else
                        yyerror("type error\n");
                };

    // simple
simple_stmts:   RETURN |
                READ var_name |
                PRINT exp |
                RETURN exp |
                PRINTLN exp
                {
                    Trace("Reducing to simple statement\n");
                } |
                var_name '=' exp 
                {
                    // assign the value to ID
                    sTableList[current_t].update(*$1->val.sVal, *$3, 0, false);
                } |
                var_name '[' exp ']' '=' exp
                {
                    // check [exp] is int or error
                    if ($3->dType == INT_)
                        // assign the value to ID[i]
                        sTableList[current_t].update(*$1->val.sVal, *$6, $3->val.iVal, true);
                    else
                        yyerror("not integer in []\n");
                };

    // function invocation
comma_separate_exp: constant_exp |
                    constant_exp ',' comma_separate_exp | ;

func_invocate:  ID '(' comma_separate_exp ')'
                {
                    // TODO: check parameters' data type
                };

    // block
block:          '{'
                {
                    // new a symbol table
                    table new_t;
                    sTableList.push_back(new_t);
                    current_t +=1;
                } _0_or_more_CONST_VAR _0_or_more_stmts '}'
                {
                    // delete the table in block
                    sTableList.pop_back();
                };

    // conditional
bool_exp:       '!' exp 
                {
                    if ($2->dType == BOOLEAN_)
                        *$$ = !(*$2);
                    else
                        yyerror("type error\n");
                } |
                exp LES exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 < *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp GRT exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 > *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp LEQ exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 <= *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp EQU exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 == *$3;
                    else if ($1->dType == $3->dType)
                        *$$ = *$1 == *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp GEQ exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 >= *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp NEQ exp 
                {
                    if ($1->dType == INT_ || $1->dType == REAL_ && $3->dType == INT_ || $3->dType == REAL_)
                        *$$ = *$1 != *$3;
                    else if ($1->dType == $3->dType)
                        *$$ = *$1 != *$3;
                    else 
                        yyerror("type error\n");
                } |
                exp AND exp 
                {
                    if ($1->dType == BOOLEAN_ && $3->dType == BOOLEAN_)
                        *$$ = *$1 && *$3;
                    else
                        yyerror("type error\n");
                } |
                exp OR exp
                {
                    if ($1->dType == BOOLEAN_ && $3->dType == BOOLEAN_)
                        *$$ = *$1 || *$3;
                    else
                        yyerror("type error\n");
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
        yyerror("Parsing error !\n");     /* syntax error */
}