%{
#include <stdlib.h>
#include <fstream>
#include "symbolTable.h"
#include "lex.yy.cpp"

void yyerror(string msg);
int listLookup(const string& name, const vector <entry>& l);
int isVarOrMethodName(const string& name, const vector<table>& tableList, const int& cur, const objType& objT);
int parameterCheck(const vector<entry>& argument, const vector<entry>& parameter);
void dump();
string printTabs();
string printType(dataType t);

vector <table> sTableList;
int current_t;
int m_count = 0;
string fileName;
string currentMethod;
int whereMethod;
int error;
fstream outputFile;
string className;
int labelNo = 1;
%}

%union {
    int intVal;
    entry* entryPt;
    char cVal;
    string* strVal;
    bool boolVal;
    vector<entry>* list;
    dataType typeVal;
}

/* keyword tokens */
%token SEMICOLON BOOLEAN BREAK CHAR CASE CLASS CONTINUE DEF DO ELSE EXIT FOR IF INT NULL_ OBJECT PRINT PRINTLN READ REPEAT RETURN TO TYPE VAL VAR WHILE ARROW

%type <entryPt> constant_exp num exp method_invocate t_f
%type <typeVal> type_
%type <list>    formal_arguments comma_separate_exp

/* other tokens */
%token <strVal> _CHAR_ STRING_ ID
%token <intVal> INTEGER
%token <boolVal> TRUE FALSE

%left OR
%left AND
%left '!'
%left LES LEQ EQU GRT GEQ NEQ
%left '-' '+'
%left '*' '/'
%nonassoc UMINUS

%%
program:    obj_declar;

    /* Data Types and Declarations */
    // any type of the variable expression
constant_exp:   _CHAR_
                {
                    entry* temp = new entry(CHAR_, $1, 0);
                    $$ = temp;
                } |
                STRING_
                {
                    // cout << "y debug: " << $1 << endl;
                    entry* temp = new entry(STR_, $1, 0);
                    $$ = temp;
                } | num | t_f;

t_f:            TRUE
                {
                    entry* temp = new entry(BOOLEAN_, $1, 0);
                    $$ = temp;
                } |
                FALSE
                {
                    entry* temp = new entry(BOOLEAN_, $1, 0);
                    $$ = temp;
                };

type_:          ':' CHAR
                {
                    $$ = dataType::CHAR_;
                } |
                ':' INT
                {
                    $$ = dataType::INT_;
                } |
                ':' BOOLEAN 
                {
                    $$ = dataType::BOOLEAN_;
                }|
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
                            entry temp($5->dType, $5->val, true);
                            sTableList[current_t].insert(*$2, temp);
                        }
                        else
                        {
                            if ($3 == $5->dType)
                            {
                                // Trace("Reducing to constant declar\n");
                                entry temp($5->dType, $5->val, true);
                                sTableList[current_t].insert(*$2, temp);
                            }
                            else
                                yyerror("type error - invalid conversion");
                        }
                    }
                    else
                    {
                        string msg = "conflicting declaration '";
                        msg += *$2 + "'";
                        yyerror(msg);
                    }
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

                        if (current_t == 1)
                        {
                            // global
                            outputFile << printTabs() << "field static ";
                            outputFile << printType(sTableList[current_t].entry_[*$2].dType);
                            outputFile << " " << *$2 << endl;
                            sTableList[current_t].entry_[*$2].eNo = -1;
                        }
                        else
                        {
                            // local
                            sTableList[current_t].entry_[*$2].eNo = sTableList[current_t].entry_.size() - 1;
                        }                
                    }
                    else
                    {
                        string msg = "conflicting declaration '";
                        msg += *$2 + "'";
                        yyerror(msg);
                    }
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

                            if (current_t == 1)
                            {
                                // global
                                outputFile << printTabs() << "field static ";
                                outputFile << printType(sTableList[current_t].entry_[*$2].dType);
                                outputFile << " " << *$2 << endl;
                                sTableList[current_t].entry_[*$2].eNo = -1;
                            }
                            else
                            {
                                // local
                                sTableList[current_t].entry_[*$2].eNo = sTableList[current_t].entry_.size() - 1;
                            }
                        }
                        else
                        {
                            if ($3 == $5->dType)
                            {
                                // Trace("Reducing to constant declar\n");
                                sTableList[current_t].insert(*$2, *$5);

                                if (current_t == 1)
                                {
                                    // global
                                    outputFile << printTabs() << "field static ";
                                    outputFile << printType(sTableList[current_t].entry_[*$2].dType);
                                    outputFile << " " << *$2 << endl;
                                    sTableList[current_t].entry_[*$2].eNo = -1;
                                }
                                else
                                {
                                    // local
                                    sTableList[current_t].entry_[*$2].eNo = sTableList[current_t].entry_.size() - 1;
                                }
                            }
                            else
                            {
                                yyerror("type error - invalid conversion");
                            }
                        }
                    }
                    else
                    {
                        string msg = "conflicting declaration '";
                        msg += *$2 + "'";
                        yyerror(msg);
                    }
                };

    /* Program Units */
data_declar:    const_declar | var_declar;
obj_content:    method_declar | data_declar | method_declar obj_content | data_declar obj_content;

obj_declar:     OBJECT ID
                {
                    // push ID into table
                    // if (sTableList[current_t].lookup(*$2, objType::OBJ) == -1)
                    // {
                        entry temp(OBJ_);
                        sTableList[current_t].insert(*$2, temp);
                        m_count = 0;
                    // }
                    // else
                    // {
                    //     string msg = "redefine object '";
                    //     msg += *$2 + "'";
                    //     linenum += 1;
                    //     yyerror(msg);
                    //     linenum -= 1;
                    // }
                    
                    outputFile << "class " << *$2 << endl << '{' << endl;
                    className = *$2;
                } '{'
                {
                    // open a new symbol table
                    table new_t;
                    sTableList.push_back(new_t);
                    current_t += 1;
                } obj_content '}'
                {
                    if (m_count < 1)
                    {
                        // linenum += 1;
                        yyerror("object needs mian() method inside");
                        // linenum -= 1;
                    }

                    // delete the table in block
                    sTableList.pop_back();
                    current_t -= 1;
                    m_count = 0;
                    
                    outputFile << '}';
                };

formal_arguments:   ID type_
                    {
                        // Trace("Reducing to formal argument\n");
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
                        {
                            // linenum += 1;
                            yyerror("formal argument needs to define type");
                            // linenum -= 1;
                        }
                    } |
                    formal_arguments ',' ID type_
                    {
                        // linenum += 1;
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
                            {
                                string msg = "redefine argument '";
                                msg += *$3 + "'";
                                yyerror(msg);
                            }
                        }
                        else
                            yyerror("formal argument needs to define type");
                        // linenum -= 1;
                    } |
                    {
                        // return empty list
                        vector<entry>* list = new vector<entry>(0);
                        $$ = list;
                    };

block_content: data_declar block_content | stmts block_content | ;

method_declar:  DEF ID '(' formal_arguments ')' type_
                {
                    // check the table no function name ID
                    if (sTableList[current_t].lookup(*$2, objType::FUNC) == -1)
                    {
                        // push ID into table
                        // and bind the argument list to ID
                        sTableList[current_t].insert(*$2, $6, *$4);
                        currentMethod = *$2;
                        whereMethod = 0;

                        outputFile << printTabs() << "method public static " \
                                   << printType($6) << " " << *$2;  // function return type and function name
                        // if function has no argument
                        if ($4->size() == 0)
                            outputFile << "(java.lang.String[])" << endl;
                        else
                        {
                            outputFile << "(";
                            // get arguments' types list into java assembly code
                            for (int i = 0; i < $4->size(); i++)
                            {
                                if (i != 0)
                                {
                                    outputFile << ", ";
                                }
                                outputFile << printType($4->at(i).dType);
                            }
                            outputFile << ")" << endl;
                        }
                        outputFile << printTabs() << "max_stack 15" << endl \
                                   << printTabs() << "max_locals 15" << endl \
                                   << printTabs() << '{' << endl;
                    }
                    else
                    {
                        string msg = "redefine method '";
                        msg += *$2 + "'";
                        yyerror(msg);
                    }
                } '{'
                {
                    // new a symbol table
                    table new_t;
                    // insert argument variable to next table
                    for (int i = 0; i < $4->size(); i++)
                    {
                        
                        entry temp($4->at(i).dType);
                        new_t.insert(*($4->at(i).val.sVal), temp);
                        new_t.entry_[*($4->at(i).val.sVal)].eNo = new_t.entry_.size() - 1;  // insert eNo
                    }
                    sTableList.push_back(new_t);
                    current_t += 1;
                    whereMethod -= 1;
                } block_content '}'
                {
                    // dump();
                    // delete the table in block
                    sTableList.pop_back();
                    current_t -= 1;
                    whereMethod += 1;
                    if (*$2 == "main")
                        m_count += 1;

                    outputFile << printTabs() << '}' << endl;
                };

    /* Statements */
stmts:          simple_stmts | block | conditional | loop;

exp:            constant_exp
                {
                    // choise assembly code by type
                    switch($1->dType)
                    {
                        case CHAR_:
                        // TODO
                            break;
                        case INT_:
                        outputFile << printTabs() << "sipush " << $1->val.iVal << endl;
                            break;
                        case BOOLEAN_:
                        outputFile << printTabs() << "iconst_" << $1->val.bVal << endl;
                            break;
                        case STR_:
                        outputFile << printTabs() << "ldc " << "bug to fix" << endl; // TODO: fix
                            break;
                    }
                } | method_invocate |
                ID
                {
                    int p;

                    if ((p = isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_)) != -1)
                    {
                        entry* temp = new entry();
                        *temp = sTableList[p].entry_[*$1];
                        if (sTableList[p].array_.find(*$1) != sTableList[p].array_.end())   // ID is array name
                            temp->dType = dataType::NTYPE;
                        
                        if (temp->isConst == 1)
                        {
                            // global or local constant
                            switch(temp->dType)
                            {
                                case CHAR_:
                                // TODO
                                    break;
                                case INT_:
                                outputFile << printTabs() << "sipush " << temp->val.iVal << endl;
                                    break;
                                case BOOLEAN_:
                                outputFile << printTabs() << "iconst_" << temp->val.bVal << endl;
                                    break;
                            }
                        }
                        else if (p < current_t && temp->isConst == 0)
                        {
                            // global variable
                            temp->val.sVal = $1;
                            temp->isConst = -1;
                            outputFile << printTabs() << "getstatic " << printType(temp->dType) << " " << className << "." << *$1 <<endl;
                        }
                        else if (p == current_t && temp->isConst == 0)
                        {
                            // local variable
                            outputFile << printTabs() << "iload " << sTableList[p].entry_[*$1].eNo << endl;
                        }
                        $$ = temp;
                        
                        // cout << "+++++++++++++++++++++++++++++++++++" << endl;
                        // cout << "type\tname\tval" << endl;
                        // cout << temp->dType << "\t" << *temp->val.sVal << "\t"  << endl;
                        // cout << "+++++++++++++++++++++++++++++++++++" << endl;
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
                    {
                        string msg = "'";
                        msg += *$1 + "' was not declared in this scope";
                        // linenum += 1;
                        yyerror(msg);
                        // linenum -= 1;
                    }
                } |
                exp '+' exp
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 + *$3;
                        outputFile << printTabs() << "iadd" << endl;
                    }
                    else 
                        yyerror("no match for 'operator+'");
                } |
                exp '-' exp
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 - *$3;
                        outputFile << printTabs() << "isub" << endl;
                    }
                    else 
                        yyerror("no match for 'operator-'");
                } |
                exp '*' exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 * *$3;
                        outputFile << printTabs() << "imul" << endl;
                    }
                    else 
                        yyerror("no match for 'operator*'");
                } |
                exp '/' exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 / *$3;
                        outputFile << printTabs() << "idiv" << endl;
                    }
                    else 
                        yyerror("no match for 'operator/'");
                } |
                '-' exp %prec UMINUS
                {
                    if ($2->dType == INT_)
                    {
                        // *$$ = -(*$2);    //don't know why segment fault int assign overload
                        entry* temp = new entry();
                        temp->dType = $2->dType;
                        $$ = temp;
                        // Trace("Reducing to exp from minus\n");
                        outputFile << printTabs() << "ineg" << endl;
                    }
                    else 
                        yyerror("no match for 'operator-'");
                } |
                '!' exp 
                {
                    if ($2->dType == BOOLEAN_)
                    {
                        *$$ = !(*$2);
                        outputFile << printTabs() << "ixor" << endl;
                    }
                    else
                        yyerror("no match for 'operator!'");
                } |
                exp LES exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 < *$3;
                        outputFile << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "iflt L" << labelNo << "_true" << endl     // if less than zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo++ << "_false:" << endl;                    // L_false
                    }
                    else 
                        yyerror("no match for 'operator<'");
                } |
                exp GRT exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 > *$3;
                        outputFile << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "ifgt L" << labelNo << "_true" << endl     // if greater than zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo++ << "_false:" << endl;                    // L_false
                    }
                    else 
                        yyerror("no match for 'operator>'");
                } |
                exp LEQ exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 <= *$3;
                        outputFile << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "ifle L" << labelNo << "_true" << endl     // if less than or equal zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo++ << "_false:" << endl;                    // L_false
                    }
                    else 
                        yyerror("no match for 'operator<='");
                } |
                exp EQU exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 == *$3;
                        outputFile << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "ifeq L" << labelNo << "_true" << endl     // if equal zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo++ << "_false:" << endl;                    // L_false
                    }
                    else if ($1->dType == $3->dType)
                    {
                        // ??
                        *$$ = *$1 == *$3;
                        if ($$->val.bVal)
                            outputFile << printTabs() << "iconst_0" << endl;
                        else
                            outputFile << printTabs() << "iconst_0" << endl;
                    }
                    else 
                        yyerror("no match for 'operator=='");
                } |
                exp GEQ exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 >= *$3;
                        outputFile << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "ifge L" << labelNo << "_true" << endl     // if greater than or equal zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo++ << "_false:" << endl;                    // L_false
                    }
                    else 
                        yyerror("no match for 'operator>='");
                } |
                exp NEQ exp 
                {
                    if ($1->dType == INT_ && $3->dType == INT_)
                    {
                        *$$ = *$1 != *$3;
                        outputFile << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "ifne L" << labelNo << "_true" << endl     // if not equal zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo++ << "_false:" << endl;                    // L_false
                    }
                    else if ($1->dType == $3->dType)
                    {
                        // ??
                        *$$ = *$1 != *$3;
                        if ($$->val.bVal)
                            outputFile << printTabs() << "iconst_0" << endl;
                        else
                            outputFile << printTabs() << "iconst_0" << endl;
                    }
                    else 
                        yyerror("no match for 'operator!='");
                } |
                exp AND exp 
                {
                    if ($1->dType == BOOLEAN_ && $3->dType == BOOLEAN_)
                    {
                        *$$ = *$1 && *$3;
                        outputFile << printTabs() << "iand" << endl;
                    }
                    else
                        yyerror("no match for 'operator&&'");
                } |
                exp OR exp
                {
                    if ($1->dType == BOOLEAN_ && $3->dType == BOOLEAN_)
                    {
                        *$$ = *$1 || *$3;
                        outputFile << printTabs() << "ior" << endl;
                    }
                    else
                        yyerror("no match for 'operator||'");
                } |
                '(' exp ')'
                {
                    $$ = $2;
                };

    // simple
simple_stmts:   exp | RETURN
                {
                    // error handle
                    if (sTableList[current_t + whereMethod].lookup(currentMethod, objType::FUNC) == -1)
                    {
                        cerr << "symbol table error" << endl;
                        exit(-1);
                    }
                    if (sTableList[current_t + whereMethod].func_[currentMethod][0].dType == NTYPE)
                    {
                        entry temp(NTYPE);
                        sTableList[current_t + whereMethod].func_[currentMethod][0] = temp;  // bind the return value

                        outputFile << printTabs() << "return" << endl;
                    }
                    else
                        yyerror("return type error - invalid conversion");
                } |
                RETURN exp
                {
                    // error handle
                    if (sTableList[current_t + whereMethod].lookup(currentMethod, objType::FUNC) == -1)
                    {
                        cerr << "symbol table error" << endl;
                        exit(-1);
                    }
                    if ($2->dType == sTableList[current_t + whereMethod].func_[currentMethod][0].dType)
                    {
                        sTableList[current_t + whereMethod].func_[currentMethod][0] = *$2;  // bind the return value

                        outputFile << printTabs() << "ireturn" << endl;
                    }
                    else
                        yyerror("return type error - invalid conversion");
                } |
                PRINT
                {
                    outputFile << printTabs() << "getstatic java.io.PrintStream java.lang.System.out" << endl;
                } exp
                {
                    outputFile << printTabs() << "invokevirtual void java.io.PrintStream.print(java.lang.String)" << endl;
                } |
                PRINTLN
                {
                    outputFile << printTabs() << "getstatic java.io.PrintStream java.lang.System.out" << endl;
                } exp
                {
                    outputFile << printTabs() << "invokevirtual void java.io.PrintStream.println(java.lang.String)" << endl;
                } |
                ID '=' exp 
                {
                    int p = isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_);
                    if (p != -1)
                    {
                        if (sTableList[p].entry_[*$1].dType == $3->dType)
                        {
                            
                            if (sTableList[p].entry_[*$1].isConst == 0)
                            {
                                // assign the value to ID
                                sTableList[p].update(*$1, *$3, 0, false);

                                if (p == current_t)
                                {
                                    // local
                                    int eNo = sTableList[p].entry_[*$1].eNo;
                                    outputFile << printTabs() << "istore " << eNo << endl;
                                }
                                else
                                {
                                    // global
                                    dataType t = sTableList[p].entry_[*$1].dType;
                                    outputFile << printTabs() << "putstatic " << printType(t) << " " << className << "." << *$1 << endl;
                                }
                            }
                            else
                            {
                                string msg = "assignment of read-only variable '";
                                msg += *$1 + "'";
                                yyerror(msg);
                            }
                        }
                        else
                            yyerror("type error(ID=exp) - invalid conversion");
                    }
                    else
                    {
                        string msg = "'";
                        msg += *$1 + "' was not declared in this scope(ID=exp)";
                        yyerror(msg);
                    }
                };

    // function invocation
comma_separate_exp: exp
                    {
                        // Trace("Reducing to comma separeate exp\n");
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
                    whereMethod -= 1;
                } block_content '}'
                {
                    // delete the table in block
                    sTableList.pop_back();
                    current_t -= 1;
                    whereMethod += 1;
                };

    // conditional
else_:          ELSE
                {
                    outputFile << printTabs() << "goto L" << labelNo << "_end" << endl
                               << "L" << labelNo << "_else:" << endl;
                } stmts
                {
                    outputFile << "L" << labelNo++ << "_end:" << endl;
                } | 
                {
                    outputFile << "L" << labelNo++ << "_else:" << endl;
                };

conditional:    IF '(' exp
                {
                    if ($3->dType != BOOLEAN_)
                    {
                        // linenum += 1;
                        yyerror("tyep error - if statement needs boolean expression in ()");
                        // linenum -= 1;
                    }
                    outputFile << printTabs() << "ifeq L" << labelNo << "_else" << endl;
                } ')' stmts else_;

    // loop
num:            INTEGER
                {
                    entry* temp = new entry(INT_, $1, 0);
                    $$ = temp;
                };

loop:           WHILE
                {
                    outputFile << "L" << labelNo << "_begin:" << endl;
                } '(' exp ')'
                {
                    if ($4->dType != BOOLEAN_)
                    {
                        // linenum += 1;
                        yyerror("tyep error - while statement needs boolean expression in ()");
                        // linenum -= 1;
                    }
                    outputFile << printTabs() << "ifeq L" << labelNo << "_end" << endl;
                } stmts
                {
                    outputFile << printTabs() << "goto L" << labelNo << "_begin" << endl
                               << "L" << labelNo++ << "_end:" << endl;
                } |
                FOR '(' ID ARROW num TO num ')'
                {
                    // linenum += 1;
                    int p;
                    if ((p = isVarOrMethodName(*$3, sTableList, current_t, objType::VAR_)) != -1)
                    {
                        entry* temp = new entry();
                        *temp = sTableList[p].entry_[*$3];
                        if (sTableList[p].array_.find(*$3) != sTableList[p].array_.end())   // ID is array name
                            temp->dType = dataType::NTYPE;
                        if (temp->dType != INT_)
                            yyerror("tyep error - invalid conversion");
                        else if (temp->isConst == 1)
                        {
                            string msg = "assignment of read-only variable '";
                            msg += *$3 + "'";
                            yyerror(msg);
                        }

                        outputFile << printTabs() << "sipush " << $5->val.iVal << endl; // push num1 on stack
                        if (p == current_t)
                        {
                            // local
                            int eNo = sTableList[p].entry_[*$3].eNo;
                            outputFile << printTabs() << "istore " << eNo << endl;
                        }
                        else
                        {
                            // global
                            dataType t = sTableList[p].entry_[*$3].dType;
                            outputFile << printTabs() << "putstatic " << printType(t) << " " << className << "." << *$3 << endl;
                        }
                        
                        outputFile << "L" << labelNo << "_begin:" << endl;
                        if (p == current_t)
                        {
                            // local
                            int eNo = sTableList[p].entry_[*$3].eNo;
                            outputFile << printTabs() << "iload " << eNo << endl;
                        }
                        else
                        {
                            // global
                            dataType t = sTableList[p].entry_[*$3].dType;
                            outputFile << printTabs() << "getstatic " << printType(t) << " " << className << "." << *$3 << endl;
                        }
                        outputFile << printTabs() << "sipush " << $7->val.iVal << endl
                                   << printTabs() << "isub" << endl                             // Subtraction
                                   << printTabs() << "iflt L" << labelNo << "_true" << endl     // if less than zero jump to true (L_true)
                                   << printTabs() << "iconst_0" << endl                         // other false
                                   << printTabs() << "goto L" << labelNo << "_false" << endl    // and jump to L_false
                                   << "L" << labelNo << "_true:" << endl                        // L_true
                                   << printTabs() << "iconst_1" << endl                         // true
                                   << "L" << labelNo << "_false:" << endl                       // L_false 
                                   << printTabs() << "ifeq L" << labelNo << "_end" << endl;     // if false leave loop
                    }
                    else
                    {
                        string msg = "'";
                        msg += *$3 + "' was not declared in this scope";
                        yyerror(msg);
                    }
                    // linenum -= 1;
                } stmts
                {
                    // find ID
                    int p;
                    if ((p = isVarOrMethodName(*$3, sTableList, current_t, objType::VAR_)) != -1)
                    {
                        // ID++
                        if (p == current_t)
                        {
                            // local
                            int eNo = sTableList[p].entry_[*$3].eNo;
                            outputFile << printTabs() << "iload " << eNo << endl;
                        }
                        else
                        {
                            // global
                            dataType t = sTableList[p].entry_[*$3].dType;
                            outputFile << printTabs() << "getstatic " << printType(t) << " " << className << "." << *$3 << endl;
                        }
                        outputFile << printTabs() << "sipush 1" << endl
                                   << printTabs() << "iadd" << endl;
                        if (p == current_t)
                        {
                            // local
                            int eNo = sTableList[p].entry_[*$3].eNo;
                            outputFile << printTabs() << "istore " << eNo << endl;
                        }
                        else
                        {
                            // global
                            dataType t = sTableList[p].entry_[*$3].dType;
                            outputFile << printTabs() << "putstatic " << printType(t) << " " << className << "." << *$3 << endl;
                        }
                        outputFile << printTabs() << "goto L" << labelNo << "_begin" << endl
                                << "L" << labelNo++ << "_end:" << endl;
                    }
                };

    /* function or procedure invocation */
method_invocate:    ID '(' comma_separate_exp ')'
                    {
                        int p = isVarOrMethodName(*$1, sTableList, current_t, objType::FUNC);
                        int q = isVarOrMethodName(*$1, sTableList, current_t, objType::VAR_);
                        if (q > p)
                        {
                            string msg = "'";
                            msg += *$1 + "' cannot be used as a function";
                            yyerror(msg);
                        }
                        else if (p != -1)
                        {
                            // check parameters' data type
                            int Flag = parameterCheck(sTableList[p].func_[*$1], *$3);
                            string msg;
                            switch (Flag)
                            {
                            case 1:
                                if (sTableList[p].func_[*$1][0].dType == NTYPE)
                                {
                                    $$ = new entry(NTYPE);  // procedure will return NTYPE
                                }
                                else
                                {
                                    entry* temp = new entry();
                                    *temp = sTableList[p].func_[*$1][0];
                                    $$ = temp;  // function will return the return value
                                }
                                // debug
                                cout << "+++++++++++++++++++++++++++++++++++" << endl;
                                cout << "type\tname\tval" << endl;
                                for (auto it = $3->begin(); it != $3->end(); it++)
                                {
                                    if (it->isConst != -1)
                                        cout << it->dType << "\t" << "\t" << it->val.iVal << endl;
                                    else
                                        cout << it->dType << "\t" << *it->val.sVal << "\t" << endl;
                                }
                                cout << "+++++++++++++++++++++++++++++++++++" << endl;

                                // parameter to assembly code
                                // for (auto it = $3->begin(); it != $3->end(); it++)
                                // {
                                //     // if (it->isConst == 1)
                                //     //     outputFile << printTabs() << "sipush " << it->val.iVal << endl;
                                //     if (it->isConst == -1)
                                //     {
                                //         // find the ID position
                                //         q = isVarOrMethodName(*it->val.sVal, sTableList, current_t, objType::VAR_);
                                //         if (q == -1)
                                //             continue;
                                //         else if (q == current_t)
                                //         {
                                //             // local
                                //             p = sTableList[q].entry_[*it->val.sVal].eNo;
                                //             outputFile << printTabs() << "iload " << p << endl;
                                //         }
                                //         else if (p < current_t)
                                //         {
                                //             // TODO: get global field
                                //             // outputFile << printTabs() << "getstatic " <<  << endl;
                                //         }
                                //     }
                                // }

                                // function call in assembly code
                                outputFile << printTabs() << "invokestatic " << printType($$->dType) << " " << className << "." << *$1 << "(";
                                for (int i = 0; i < $3->size(); i++)
                                {
                                    if (i != 0)
                                    {
                                        outputFile << ", ";
                                    }
                                    outputFile << printType($3->at(i).dType);
                                }
                                outputFile << ")" << endl;
                                break;
                            case -1:
                                yyerror("invalid parameter type");
                                break;
                            case -2:
                                msg = "too few arguments to function '";
                                msg += *$1 + "'";
                                yyerror(msg);
                                break;
                            case -3:
                                msg = "too many arguments to function '";
                                msg += *$1 + "'";
                                yyerror(msg);
                                break;
                            }
                        }
                        else
                        {
                            string msg = "'";
                            msg += *$1 + "' was not declared in this scope";
                            yyerror(msg);
                        }
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
    fileName = argv[1];

    table mainTable;
    sTableList.push_back(mainTable);
    current_t = 0;
    error = 0;
    string temp = fileName.erase(fileName.length() - 5, 5) + "jasm";
    outputFile.open(temp, std::ios::out);
    cout << "writing to file: " << temp << endl;

    /* perform parsing */
    if (yyparse() == 1)                 /* parsing */
    {
        // linenum += 1;
        cout << "Parsing error !" << endl;     /* syntax error */
    }

    cout << "total error: " << error << endl << endl;
    outputFile.close();
}

void yyerror(string msg)
{
    cerr << fileName << ":" << linenum << ": error: "; // TODO
    cerr << msg << endl;
    error += 1;
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
    int p = cur;
    // check all previous table
    while (p >= 0)
    {
        // lookup the symbol table and return variable's name
        if (tableList[p].lookup(name, objT) != -1)
            return p;
        p -= 1;
    }
    return -1;
}

int parameterCheck(const vector<entry>& argument, const vector<entry>& parameter)
{
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

void dump()
{
    for (int i = current_t; i >= 0; i--)
    {
        cout << "table " << i << endl << endl;
        sTableList[i].dump();
        cout << endl;
    }
    cout << "====================" << endl;
}

string printTabs()
{
    string result = "";
    for (int i = 0; i < current_t; i++)
        result += '\t';
    return result;
}

string printType(dataType type)
{
    switch (type)  // function type
    {
        case CHAR_:
        return "char";
            break;
        case INT_:
        return "int";
            break;
        case BOOLEAN_:
        return "int";
            break;
        case NTYPE:
        return "void";
            break;
        default:
        return "int";
            break;
    }
}