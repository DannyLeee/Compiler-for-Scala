%{
#include <stdlib.h>
#include "symbolTable.h"
#include "lex.yy.cpp"
#define Trace(t)        printf(t)

void yyerror(string msg)
{
    cerr << msg << endl;
}

int listLookup(const string& name, const vector <entry>& l)
{
    for (int i = 0; i < l.size(); i++)
    {
        if (name == *l[i].val.sVal)
            return 1;
    }
    return -1;
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
    vector<entry>* list;
    dataType typeVal;
}



/* keyword tokens */
%token SEMICOLON BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT NULL_ OBJECT PRINT PRINTLN READ REPEAT RETURN STRING TO TYPE VAL VAR WHILE

/* other tokens */
%token OR AND LES LEQ EQU GRT GEQ NEQ

%type <entryPt> constant_exp num exp bool_exp var_name
%type <typeVal> type_
%type <list> formal_arguments

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
                TRUE
                {
                    entry* temp = new entry(BOOLEAN_, $1, true);
                    $$ = temp;
                } | FALSE
                {
                    entry* temp = new entry(BOOLEAN_, $1, true);
                    $$ = temp;
                };

type_:          ':' CHAR
                {
                    dataType t = static_cast <dataType> (CHAR_);   // int to enum
                    $$ = t;
                } |
                ':' STRING
                {
                    dataType t = static_cast <dataType> (STR_);   // int to enum
                    $$ = t;
                } |
                ':' INT
                {
                    dataType t = static_cast <dataType> (INT_);   // int to enum
                    $$ = t;
                } |
                ':' BOOLEAN 
                {
                    dataType t = static_cast <dataType> (BOOLEAN_);   // int to enum
                    $$ = t;
                }|
                ':' FLOAT 
                {
                    dataType t = static_cast <dataType> (REAL_);   // int to enum
                    $$ = t;
                } |
                {
                    dataType t = static_cast <dataType> (NTYPE);   // int to enum
                    $$ = t;
                };

const_declar:   VAL ID type_ '=' constant_exp
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2, false) == -1)
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
                    if (sTableList[current_t].lookup(*$2, false) == -1)
                    {
                        // insert symbol table
                        if ($3 == NTYPE)
                        {
                            entry temp;
                            sTableList[current_t].insert(*$2, temp);
                        }
                        else
                        {
                            entry temp($3);
                            sTableList[current_t].insert(*$2, temp);
                        }
                    }
                    else
                        yyerror("conflicting declaration\n");
                } |
                VAR ID type_ '=' constant_exp
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2, false) == -1)
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
                    if (sTableList[current_t].lookup(*$2, false) == -1)
                    {
                        // insert symbol table
                        if ($3 == NTYPE)
                            yyerror("array don't has type\n");
                        else if ($5->dType != INT_)
                            yyerror("not integer inside []\n");
                        else
                        {
                            sTableList[current_t].insert(*$2, $3, $5->val.iVal);
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

formal_arguments:   ID type_
                    {
                        Trace("Reducing to formal argument\n");
                        Trace("debug: ");
                        cout << "name: " << $1 << "type: " << $2 << endl;
                        // check type_ not NTYPE
                        if ($2 != NTYPE)
                        {
                            // new a vector<entry> to store whole formal argument
                            vector<entry>* arguList = new vector<entry>;
                            entry temp($2, $1);
                            arguList->push_back(temp);
                            $$ = arguList;
                        }
                        else
                            yyerror("formal argument needs type\n");
                    } |
                    formal_arguments ',' ID type_
                    {
                        // check type_ not NTYPE
                        if ($4 != NTYPE)
                        {
                            // check the list hasn't have argument name ID
                            if (listLookup(*$3, *$1) == -1)
                            {
                                // push back the new argument to the vector
                                entry temp($4, $3);
                                $1->push_back(temp);
                                $$ = $1;
                            }
                            else
                                yyerror("redefinition argument\n");
                        }
                        else
                            yyerror("formal argument needs type\n");
                    } |
                    {
                        // return empty list
                        vector<entry>* list = new vector<entry>(0);
                        $$ = list;
                    };

_0_or_more_stmts: stmts _0_or_more_stmts | ;
method_declar:  DEF ID '(' formal_arguments ')' type_ 
                {
                    // check the table no function name ID
                    if (sTableList[current_t].lookup(*$2, true) == -1)
                    {
                        // bind the argument list to ID
                        sTableList[current_t].insert(*$2, $6, *$4);
                    }
                    else
                        yyerror("redefinition method\n");
                } block;

    /* Statements */
stmts:          exp | simple_stmts | block | conditional | loop;

var_name:       ID
                {
                    // TODO: check all previous table
                    // lookup the symbol table and return variable's name
                    if (sTableList[current_t].lookup(*$1, false))
                    {
                        entry temp(NAME_, $1, true);
                        *$$ = temp; // return an entry dType: NAME_, value: ID 
                    }
                    else
                        yyerror("no variable name\n");
                };

exp:            num | constant_exp | bool_exp | var_name |
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
                func_or_procedure_invocate
                {
                    // TODO
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

    /* function or procedure invocation */
func_or_procedure_invocate: ID
                            {
                                // TODO: procedure only
                            } |
                            ID '(' comma_separate_exp ')'
                            {
                                // TODO: check parameters' data type
                                // function return the function return type
                                // procedure return NTYPE
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