%{
#include <stdlib.h>
#include "symbolTable.h"
#include "lex.yy.cpp"
#define Trace(t)        printf(t)

void yyerror(string msg)
{
    cerr << msg << endl;
    exit(-1);   // TODO: remove it
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

int isVarOrMethodName(const string& name, const vector<table>& tableList, const int& cur, const objType& objT)
{
    // cout << "yacc debug: current_t= " << cur << endl;
    // for (int i = cur; i >= 0; i--)
    // {
    //     cout << "table " << i << endl;
    //     tableList[i].dump();
    //     cout << endl;
    // }
    int p = cur;
    // check all previous table
    while (p >= 0)
    {
        // lookup the symbol table and return variable's name
        if (tableList[p].lookup(name, objT) != -1)
        {
            cout << "yacc debug: find " << name << " at table" << p << endl;
            return p;
        }
        p -= 1;
    }
    return -1;
}

int parameterCheck(const vector<entry>& argument, const vector<entry>& parameter)
{
    cout << "yacc debug: " << argument.size() << " " << parameter.size() << endl;
    if (argument.size() > parameter.size() + 1)
        return -2;
    else if (argument.size() < parameter.size() + 1)
        return -3;
    for (int i = 0; i < parameter.size(); i++)
    {
        if (argument[i + 1].dType != parameter[i].dType)
            return -1;
    }
    return 1;
}

vector <table> sTableList;
int current_t;
int m_count;
%}

%union {
    int intVal;
    entry* entryPt;
    char cVal;
    string* strVal;
    double realVal;
    bool boolVal;
    vector<entry>* list;
    dataType typeVal;
}

/* keyword tokens */
%token SEMICOLON BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FLOAT FOR IF INT NULL_ OBJECT PRINT PRINTLN READ REPEAT RETURN STRING TO TYPE VAL VAR WHILE

%type <entryPt> constant_exp num exp bool_exp method_invocate return_ t_f
%type <typeVal> type_
%type <list>    formal_arguments comma_separate_exp

/* other tokens */
%token <strVal> _CHAR_ STRING_ ID
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
constant_exp:   _CHAR_
                {
                    entry* temp = new entry(CHAR_, $1, false);
                    $$ = temp;
                } |
                STRING_
                {
                    entry* temp = new entry(STR_, $1, false);
                    $$ = temp;
                } | num | bool_exp;

t_f:            TRUE
                {
                    entry* temp = new entry(BOOLEAN_, $1, false);
                    $$ = temp;
                } |
                FALSE
                {
                    entry* temp = new entry(BOOLEAN_, $1, false);
                    $$ = temp;
                };

type_:          ':' CHAR
                {
                    $$ = dataType::CHAR_;
                } |
                ':' STRING
                {
                    $$ = dataType::STR_;
                } |
                ':' INT
                {
                    $$ = dataType::INT_;
                } |
                ':' BOOLEAN 
                {
                    $$ = dataType::BOOLEAN_;
                }|
                ':' FLOAT 
                {
                    $$ = dataType::REAL_;
                } |
                {
                    $$ = dataType::NTYPE;
                };

const_declar:   VAL ID type_ '=' exp
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2, objType::VAR_) == -1)
                    {
                        // insert symbol table
                        if ($3 == NTYPE)
                        {
                            sTableList[current_t].insert(*$2, *$5);
                            cout << "yacc debug: insert " << *$2 << " at table " << current_t << endl;
                        }
                        else
                        {
                            if ($3 == $5->dType)
                            {
                                Trace("Reducing to constant declar\n");
                                entry temp($5->dType, $5->val, true);
                                sTableList[current_t].insert(*$2, temp);
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
                    if (sTableList[current_t].lookup(*$2, objType::VAR_) == -1)
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
                VAR ID type_ '=' exp
                {
                    // check the symbol table first
                    if (sTableList[current_t].lookup(*$2, objType::VAR_) == -1)
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
                    if (sTableList[current_t].lookup(*$2, objType::VAR_) == -1)
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
data_declar:    const_declar | var_declar | array_declar;
obj_content:    method_declar | data_declar | method_declar obj_content | data_declar obj_content;

obj_declar:     OBJECT ID
                {
                    // push ID into table
                    if (sTableList[current_t].lookup(*$2, objType::OBJ) == -1)
                    {
                        entry temp(OBJ_);
                        sTableList[current_t].insert(*$2, temp);
                        m_count = 0;
                    }
                    else
                        yyerror("redefinition object\n");
                } '{'
                {
                    // open a new symbol table
                    table new_t;
                    sTableList.push_back(new_t);
                    current_t += 1;
                } obj_content '}'
                {
                    // cout << "yacc debug: current_t= " << current_t << endl;
                    // for (int i = current_t; i >= 0; i--)
                    // {
                    //     cout << "table " << i << endl;
                    //     sTableList[i].dump();
                    //     cout << endl;
                    // }
                    if (m_count < 1)
                        yyerror("object needs atleast one method inside\n");

                    // delete the table in block
                    sTableList.pop_back();
                    current_t -= 1;
                    m_count = 0;
                };

formal_arguments:   ID type_
                    {
                        Trace("Reducing to formal argument\n");
                        // cout <<"yacc debug: " << "name: " << *$1 << " type: " << $2 << endl;
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
                                cout << "yacc debug: " << "name: " << *$3 << " type: " << $4 << endl;
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

block_content: data_declar block_content | stmts block_content | ;

return_:        RETURN
                {
                    $$ = new entry(NTYPE);
                } |
                RETURN exp
                {
                    $$ = $2;
                } |
                {
                    $$ = new entry(NTYPE);
                };

method_declar:  DEF ID '(' formal_arguments ')' type_
                {
                    // check the table no function name ID
                    if (sTableList[current_t].lookup(*$2, objType::FUNC) == -1)
                    {
                        // push ID into table
                        // and bind the argument list to ID
                        sTableList[current_t].insert(*$2, $6, *$4);
                        cout << "yacc debug: insert " << *$2 << " at table" << current_t << endl;
                    }
                    else
                        yyerror("redefinition method\n");
                } '{'
                {
                    // new a symbol table
                    table new_t;
                    // insert argument variable to next table
                    for (int i = 0; i < $4->size(); i++)
                    {
                        entry temp($4->at(i).dType);
                        new_t.insert(*($4->at(i).val.sVal), temp);
                    }
                    sTableList.push_back(new_t);
                    current_t += 1;
                } block_content return_
                {
                    // cout << "yacc debug " << $12->dType << " " << $6 << endl;
                    if ($11->dType == $6)
                        sTableList[current_t - 1].func_[*$2][0] = *$11;  // bind the return value
                    else
                        yyerror("wrong return type\n");
                } '}'
                {
                    // delete the table in block
                    sTableList.pop_back();
                    current_t -= 1;
                    m_count += 1;
                };

    /* Statements */
stmts:          exp
                {
                    delete $1;
                } | simple_stmts | block | conditional | loop;

exp:            constant_exp
                {
                    $$ = $1;
                    cout << "yacc debug (exp): " << $$->dType << " " << $$->val.iVal << " " << $$->isConst << endl;
                } |
                method_invocate
                {
                    $$ = $1;
                    cout << "yacc debug (exp): " << $$->dType << " " << $$->val.iVal << endl;
                } |
                ID
                {
                    int p;

                    if ((p = isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_)) != -1)
                    {
                        // copy constructor
                        // entry temp = sTableList[p].entry_[*$1];
                        // $$ = &temp;
                        // cout << "type: " << $$->dType << " val: " << $$->val.iVal << endl;

                        entry* temp = new entry();
                        *temp = sTableList[p].entry_[*$1];
                        $$ = temp;
                        cout << "yacc debug(exp): type: " << $$->dType << " val: " << $$->val.iVal << endl;
                        Trace("Reducing to exp from ID\n");
                    }
                    else if ((p = isVarOrMethodName(*$1, sTableList, current_t, objType::FUNC)) != -1)
                    {
                        // method invocate
                        entry* temp = new entry();
                        *temp = sTableList[p].func_[*$1][0];
                        $$ = temp;
                        // P3TODO:
                    }
                    else
                        yyerror("varirable or method name not found\n");
                } |
                exp '+' exp
                {
                    cout <<"yacc debug (+): " << "type1: " << $1->dType << " val1: " << $1->val.iVal << " type2: " << $3->dType << " val2: " << $3->val.iVal << endl;
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 + *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp '-' exp
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                    {
                        *$$ = *$1 - *$3;
                        Trace("Reducing to exp from sub\n");
                    }
                    else 
                        yyerror(" operand type error\n");
                } |
                exp '*' exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 * *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp '/' exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 / *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp '%' exp
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                        *$$ = *$1 % *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                '-' exp %prec UMINUS
                {
                    cout << "yacc debug: type: " << $2->dType << endl;
                    if ($2->dType == INT_ || $2->dType == REAL_)
                    {
                        cout << "test0" << endl;
                        // *$$ = -(*$2);    //don't know why segment fault int assign overload
                        entry* temp = new entry();
                        temp->dType = $2->dType;
                        cout << "test2" << endl;
                        Trace("Reducing to exp from minus\n");
                    }
                    else 
                        yyerror("operand type error\n");
                } |
                '(' exp ')'
                {
                    $$ = $2;
                };

    // simple
simple_stmts:   PRINT exp
                {
                    Trace("Reducing to simple stmt\n");
                } | PRINTLN exp |
                READ ID
                {
                    int p = isVarOrMethodName(*$2, sTableList, current_t, objType::VAR_);
                    if (p != -1)
                    {
                        // P3TODO:
                    }
                    else
                        yyerror("varirable name not found\n");
                } |
                ID '=' exp 
                {
                    // cout << "yacc debug: current_t= " << current_t << endl;
                    // for (int i = current_t; i >= 0; i--)
                    // {
                    //     cout << "table " << i << endl;
                    //     sTableList[i].dump();
                    //     cout << endl;
                    // }

                    int p = isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_);
                    if (p != -1)
                    {
                        if (sTableList[p].entry_[*$1].isConst == false)
                            // assign the value to ID
                            sTableList[p].update(*$1, *$3, 0, false);
                        else
                            yyerror("assignment of constant variable\n");
                    }
                    else
                        yyerror("varirable name not found\n");
                } |
                ID '[' exp ']' '=' exp
                {
                    int p = isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_);
                    if (p != -1)
                    { 
                        // check [exp] is int or error
                        if ($3->dType == INT_)
                            // assign the value to ID[i]
                            sTableList[p].update(*$1, *$6, $3->val.iVal, true);
                        else
                            yyerror("not integer in []\n");
                    }
                    else
                        yyerror("varirable name not found\n");
                };

    // function invocation
comma_separate_exp: exp
                    {
                        Trace("Reducing to comma separeate exp\n");
                        cout << "yacc debug: " << "type: " << $1->dType << endl;
                        // new a vector<entry> to store whole formal parameter
                        vector<entry>* parameterList = new vector<entry>;
                        parameterList->push_back(*$1);
                        $$ = parameterList;
                    } |
                    comma_separate_exp ',' exp
                    {
                        // push back the new parameter to the vector
                        $1->push_back(*$3);
                        $$ = $1;
                    } |
                    {
                        // return empty list
                        vector<entry>* list = new vector<entry>(0);
                        $$ = list;
                    };

    // block
block:          '{'
                {
                    // new a symbol table
                    table new_t;
                    sTableList.push_back(new_t);
                    current_t +=1;
                } block_content '}'
                {
                    // delete the table in block
                    sTableList.pop_back();
                    current_t -= 1;
                };

    // conditional
bool_exp:       t_f |
                '!' exp 
                {
                    if ($2->dType == BOOLEAN_)
                        *$$ = !(*$2);
                    else
                        yyerror("operand type error\n");
                } |
                exp LES exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 < *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp GRT exp 
                {
                    // cout << "yacc debug: current_t= " << current_t << endl;
                    // for (int i = current_t; i >= 0; i--)
                    // {
                    //     cout << "table " << i << endl;
                    //     sTableList[i].dump();
                    //     cout << endl;
                    // }

                    cout <<"yacc debug (>): " << "type1: " << $1->dType << " val1: " << $1->val.iVal << " type2: " << $3->dType << " val2: " << $3->val.iVal << endl;

                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 > *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp LEQ exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 <= *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp EQU exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 == *$3;
                    else if ($1->dType == $3->dType)
                        *$$ = *$1 == *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp GEQ exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 >= *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp NEQ exp 
                {
                    if (($1->dType == INT_ || $1->dType == REAL_) && ($3->dType == INT_ || $3->dType == REAL_))
                        *$$ = *$1 != *$3;
                    else if ($1->dType == $3->dType)
                        *$$ = *$1 != *$3;
                    else 
                        yyerror("operand type error\n");
                } |
                exp AND exp 
                {
                    if ($1->dType == BOOLEAN_ && $3->dType == BOOLEAN_)
                        *$$ = *$1 && *$3;
                    else
                        yyerror("operand type error\n");
                } |
                exp OR exp
                {
                    if ($1->dType == BOOLEAN_ && $3->dType == BOOLEAN_)
                        *$$ = *$1 || *$3;
                    else
                        yyerror("operand type error\n");
                };

conditional:    IF '(' bool_exp ')' stmts |
                IF '(' bool_exp ')' stmts ELSE stmts;

    // loop
num:            REAL
                {
                    entry* temp = new entry(REAL_, $1, false);
                    $$ = temp;
                } |
                INTEGER
                {
                    entry* temp = new entry(INT_, $1, false);
                    $$ = temp;
                    cout << "yacc debug (num): " << $$->dType << " " << $$->val.iVal << endl;
                };

loop:           WHILE '(' bool_exp ')' block |
                WHILE '(' bool_exp ')' simple_stmts |
                FOR '(' ID '<''-' num TO num ')' block |
                FOR '(' ID '<''-' num TO num ')' simple_stmts;

    /* function or procedure invocation */
method_invocate:    ID '(' comma_separate_exp ')'
                    {
                        int p = isVarOrMethodName(*$1, sTableList, current_t, objType::FUNC);
                        if (p != -1)
                        {
                            // check parameters' data type
                            int Flag = parameterCheck(sTableList[p].func_[*$1], *$3);
                            // cout << "yacc debug: current_t= " << current_t << " p= " << p << endl;
                            // for (int i = p; i >= 0; i--)
                            // {
                            //     cout << "table " << i << endl;
                            //     sTableList[i].dump();
                            //     cout << endl;
                            // }

                            switch (Flag)
                            {
                            case 1:
                                if (sTableList[p].func_[*$1][0].dType == NTYPE)
                                {
                                    $$ = new entry(NTYPE);  // procedure will return NTYPE
                                    // P3TODO:
                                }
                                else
                                {
                                    entry* temp = new entry();
                                    *temp = sTableList[p].func_[*$1][0];
                                    $$ = temp;  // function will return the return value 
                                    cout << "yacc debug: type: " << $$->dType << " val: " << $$->val.iVal << endl;
                                    // P3TODO:
                                }
                                break;
                            case -1:
                                yyerror("parameter type error\n");
                                break;
                            case -2:
                                yyerror(" too few arguments\n");
                                break;
                            case -3:
                                yyerror(" too many arguments\n");
                                break;
                            }
                        }
                        else if (isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_))
                            yyerror("not a function");
                        else
                            yyerror("method name not found\n");
                        
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
    current_t = 0;

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
        yyerror("Parsing error !\n");     /* syntax error */
}