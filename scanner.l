%{
/* C Declarations and Includes */

#include "y.h"
#define LIST     strcat(buf,yytext)
#define TOUPPER(s, temp) for (int i = 0; i < strlen(s); i++) {temp[i] = toupper(s[i]); temp[i+1] = 0;} 
#define token(t) {LIST; printf("<'%s'>\n",t); return *t;}
#define tokenKeyword(t) {LIST; printf("<%s>\n",t);}
#define tokenInteger(t,i) {LIST; printf("<%s: %d>\n",t,atoi(i));}
#define tokenFloat(t,f) {LIST; printf("<%s: %f>\n",t,atof(f));}
#define tokenString(t,s) {LIST; printf("<%s%s>\n",t,s);}

#define MAX_LINE_LENG 256

int linenum = 1;
char buf[MAX_LINE_LENG];
%}

/* regular definition */
/* symbol */
delimiters  [,:.;()\[\]{}]
arithmetic   [+\-*/]

/* basic component */
alphabet    [a-zA-Z]
digit       [0-9]

/* identifier*/
/* [a-zA-Z][a-zA-Z0-9]* */
id          {alphabet}({alphabet}|{digit})*

/* number system */
integer     {digit}+
plain_real  {digit}+"."{digit}+ 
expreal     {digit}+"."{digit}+[Ee][+-]?{digit}+
real        {plain_real}|{expreal}

/* state */
%x C_COMMENT
%x COMMENT

%%
    /* Delimiters */
    /* [,:.;()\[\]{}]      {token(yytext);} */
{delimiters}    {token(yytext);}

    /* Arithmetic */
{arithmetic}    {token(yytext);}

    /* Remainder */
    /* "%"             {token(yytext);}*/

    /* Relational */
"<"               {return LES;}
"<="              {return LEQ;}
">="              {return GEQ;}
">"               {return GRT;}
"=="              {return EQU;}
"!="              {return NEQ;}

    /* Logical */
&&              {return AND;}
\|\|            {return OR;}
!               {token(yytext);}

    /* assign */
"="             {token(yytext);}

    /* Keywords*/
boolean {
    tokenKeyword(yytext);
    return BOOLEAN;
}

break   {
    tokenKeyword(yytext);
    return BREAK;
}

char    {
    tokenKeyword(yytext);
    return CHAR;
}

case    {
    tokenKeyword(yytext);
    return CASE;
}

class   {
    tokenKeyword(yytext);
    return CLASS;
}

continue    {
    tokenKeyword(yytext);
    return CONTINUE;
}

def {
    tokenKeyword(yytext);
    return DEF;
}

do  {
    tokenKeyword(yytext);
    return DO;
}

else    {
    tokenKeyword(yytext);
    return ELSE;
}

exit    {
    tokenKeyword(yytext);
    return EXIT;
}

false   {
    tokenKeyword(yytext);
    return FALSE;
}

float   {
    tokenKeyword(yytext);
    return FLOAT;
}

for {
    tokenKeyword(yytext);
    return FOR;
}

if  {
    tokenKeyword(yytext);
    return IF;
}

int {
    tokenKeyword(yytext);
    return INT;
}

null    {
    tokenKeyword(yytext);
    return NULL_;
}

object  {
    tokenKeyword(yytext);
    return OBJECT;
}

print   {
    tokenKeyword(yytext);
    return PRINT;
}

println {
    tokenKeyword(yytext);
    return PRINTLN;
}

read    {
    tokenKeyword(yytext);
    return READ;
}

repeat  {
    tokenKeyword(yytext);
    return REPEAT;
}

return  {
    tokenKeyword(yytext);
    return RETURN;
}

string  {
    tokenKeyword(yytext);
    return STRING;
}

to  {
    tokenKeyword(yytext);
    return TO;
}

true    {
    tokenKeyword(yytext);
    return TRUE;
}

type    {
    tokenKeyword(yytext);
    return TYPE;
}

val {
    tokenKeyword(yytext);
    return VAL;
}

var {
    tokenKeyword(yytext);
    return VAR;
}

while   {
    tokenKeyword(yytext);
    return WHILE;
}

    /* identifiers */
{id}        {
    tokenString("id: ", yytext);
    string temp = yytext;
    // sTable.insert(temp, 0);
    return ID;
}

    /* integer */
{integer}   {
    tokenInteger("integer", yytext);
    return INTEGER;
}

    /* Real */
{real}      {
    tokenFloat("real", yytext);
    return REAL;
}

    /* string */
\"[^"^\n]*\"   {
    char c = getc(yyin);   // next character   // yytext no change
    if (c == '\"') {
        ungetc(c, yyin);
        yymore();   // yytext no change            
    }
    else {
        char * temp = new char[yyleng  + 1];
        strcpy(temp, yytext);
        strcpy(temp, temp + 1);
        temp[strlen(temp) - 1] = 0;
        char *l, *r;
        for (int i = 0; i < strlen(temp); i++)
        {
            if (temp[i] == '\"' && temp[i + 1] == '\"')
            {
                l = new char[i + 1];
                strcpy(l, temp);
                l[i] = 0;
                r = new char[strlen(temp) - i + 1];
                strcpy(r, temp + i + 1);
                
                strcat(l, r);
                memset(temp, 0, strlen(temp));
                strcpy(temp,l);
                delete(l);
                delete(r);
            }
        }
        tokenString("string:", temp);
        delete(temp);
        ungetc(c, yyin);   // yytext no change
        return STRING_;
    }
}

    /* single line comment */
"//"        {
    LIST;
    BEGIN(COMMENT);
}

<COMMENT>\n {
    LIST;
    printf("%d: %s", linenum++, buf);
    memset(buf, 0, MAX_LINE_LENG);
    BEGIN(INITIAL);
}

<COMMENT>.  {LIST;}

    /* multi lines comment */
"/*"    {
    LIST;
    BEGIN(C_COMMENT);
}
<C_COMMENT>"*/" {
    LIST;
    BEGIN(INITIAL);
}
<C_COMMENT>\n   {
    LIST;
    printf("%d: %s", linenum++, buf);
    memset(buf, 0, MAX_LINE_LENG);
}
<C_COMMENT>.    {LIST;}

\n      {
            LIST;
            printf("%d: %s", linenum++, buf);
            memset(buf, 0, MAX_LINE_LENG);
        }

[ \t]*  {LIST;}

.       {
            LIST;
            printf("%d:%s\n", linenum, buf);
            printf("bad character:'%s'\n",yytext);
            exit(-1);
        }

%%
// int main (int argc, char* argv[]) {
//     sTable = create();
//     yyin = fopen(argv[1], "r");
//     yylex();
//     printf("\nSymbol Table:\n");
//     sTable.dump();
//     fclose(yyin);
// }

int yywrap() {
    printf("%d: %s\n", linenum, buf);
    return 1;
}